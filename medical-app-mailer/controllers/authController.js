const { promisify } = require("util");
const jwt = require("jsonwebtoken");
const User = require("../models/userModel");
const Patient = require("../models/patientModel");
const Medecin = require("../models/medecinModel");
const catchAsync = require("../utils/catchAsync");
const AppError = require("../utils/appError");
const sendEmail = require("../utils/email");
const admin = require("firebase-admin");
//-----------------------------------------

//-----------------------------------------

//----------- Sign Up ---------------------

// Helper function to sign JWT token
const signToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRE_IN,
  });
};

// Helper function to generate refresh token
const generateRefreshToken = (userId) => {
  const refreshToken = jwt.sign(
    { id: userId },
    process.env.REFRESH_TOKEN_SECRET,
    {
      expiresIn: process.env.REFRESH_TOKEN_EXPIRE_IN,
    }
  );
  return refreshToken;
};

// Helper function to create and send tokens
const createSendToken = (user, statusCode, res) => {
  const token = signToken(user._id);
  const refreshToken = generateRefreshToken(user._id);

  // Save refresh token to user
  user.refreshToken = refreshToken;
  user.save({ validateBeforeSave: false });

  // Remove password from output
  user.password = undefined;

  res.status(statusCode).json({
    status: "success",
    token,
    refreshToken,
    data: { user },
  });
};

// Sign up controller
exports.signUp = catchAsync(async (req, res, next) => {
  // Check required fields
  if (
    !req.body.email ||
    !req.body.password ||
    !req.body.passwordConfirm ||
    !req.body.name ||
    !req.body.lastName ||
    !req.body.phoneNumber ||
    !req.body.gender ||
    !req.body.role
  ) {
    return next(
      new AppError(
        "Veuillez remplir tous les champs obligatoires !",
        400
      )
    );
  }

  // Check if email already exists
  const existingUser = await User.findOne({ email: req.body.email });
  if (existingUser) {
    return next(new AppError("Cet e-mail est déjà utilisé !", 400));
  }

  let newUser;

  // Create user based on role
  if (req.body.role === "patient") {
    if (!req.body.antecedent) {
      return next(
        new AppError(
          "Veuillez fournir vos antécédents médicaux !",
          400
        )
      );
    }

    newUser = await Patient.create({
      name: req.body.name,
      lastName: req.body.lastName,
      email: req.body.email,
      password: req.body.password,
      passwordConfirm: req.body.passwordConfirm,
      phoneNumber: req.body.phoneNumber,
      gender: req.body.gender,
      dateOfBirth: req.body.dateOfBirth,
      role: req.body.role,
      antecedent: req.body.antecedent,
    });
  } else if (req.body.role === "medecin") {
    if (!req.body.speciality) {
      return next(
        new AppError("Veuillez fournir votre spécialité !", 400)
      );
    }

    newUser = await Medecin.create({
      name: req.body.name,
      lastName: req.body.lastName,
      email: req.body.email,
      password: req.body.password,
      passwordConfirm: req.body.passwordConfirm,
      phoneNumber: req.body.phoneNumber,
      gender: req.body.gender,
      dateOfBirth: req.body.dateOfBirth,
      role: req.body.role,
      speciality: req.body.speciality,
      numLicence: req.body.numLicence,
      appointmentDuration: req.body.appointmentDuration || 30,
    });
  } else {
    return next(new AppError("Rôle non valide !", 400));
  }

  // Generate verification code
  const verificationCode = newUser.createVerificationCode();
  await newUser.save({ validateBeforeSave: false });

  // Send verification email
  try {
    const message = `Bonjour,\n
    Merci de créer un compte sur notre plateforme.\n
    Pour activer votre compte, voici votre code de vérification: ${verificationCode}\n
    Ce code est valable pendant 30 minutes.`;

    await sendEmail({
      email: newUser.email,
      subject: "Activation de compte",
      message,
    });

    res.status(201).json({
      status: "success",
      message: "Votre code d'activation a été envoyé avec succès",
    });
  } catch (err) {
    console.log(err);
    return next(
      new AppError(
        "Une erreur s'est produite lors de l'envoi de l'e-mail ! Merci d'essayer plus tard.",
        500
      )
    );
  }
});

// Verify account
exports.verifyAccount = catchAsync(async (req, res, next) => {
  const { email, verificationCode } = req.body;

  if (!email || !verificationCode) {
    return next(
      new AppError(
        "Veuillez fournir votre email et code de vérification",
        400
      )
    );
  }

  const user = await User.findOne({
    email,
    verificationCode,
    validationCodeExpiresAt: { $gt: Date.now() },
  });

  if (!user) {
    return next(
      new AppError("Code de vérification invalide ou expiré", 400)
    );
  }

  user.accountStatus = true;
  user.verificationCode = undefined;
  user.validationCodeExpiresAt = undefined;
  await user.save({ validateBeforeSave: false });

  createSendToken(user, 200, res);
});

// Login controller
exports.login = catchAsync(async (req, res, next) => {
  const { email, password } = req.body;

  // Check if email and password exist
  if (!email || !password) {
    return next(
      new AppError(
        "Veuillez fournir votre email et mot de passe",
        400
      )
    );
  }

  // Check if user exists and password is correct
  const user = await User.findOne({ email }).select("+password");

  if (
    !user ||
    !(await user.correctPassword(password, user.password))
  ) {
    return next(new AppError("Email ou mot de passe incorrect", 401));
  }

  // Check if user account is activated
  if (!user.accountStatus) {
    return next(
      new AppError(
        "Votre compte n'est pas encore activé ! Veuillez l'activer pour vous connecter",
        401
      )
    );
  }

  // If everything is ok, send token to client
  createSendToken(user, 200, res);
});

// Protect routes middleware
exports.protect = catchAsync(async (req, res, next) => {
  // Get token and check if it exists
  let token;
  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith("Bearer")
  ) {
    token = req.headers.authorization.split(" ")[1];
  }

  if (!token) {
    return next(
      new AppError(
        "Vous n'êtes pas connecté ! Veuillez vous connecter pour accéder à cette route.",
        401
      )
    );
  }

  // Verify token
  const decoded = await promisify(jwt.verify)(
    token,
    process.env.JWT_SECRET
  );

  // Check if user still exists
  const currentUser = await User.findById(decoded.id);
  if (!currentUser) {
    return next(new AppError("L'utilisateur n'existe plus !", 401));
  }

  // Grant access to protected route
  req.user = currentUser;
  next();
});

// Restrict to certain roles
exports.restrictTo = (...roles) => {
  return (req, res, next) => {
    if (!roles.includes(req.user.role)) {
      return next(
        new AppError(
          "Vous n'avez pas la permission d'effectuer cette action",
          403
        )
      );
    }
    next();
  };
};

// Forgot password
exports.forgotPassword = catchAsync(async (req, res, next) => {
  // Get user based on email
  const user = await User.findOne({ email: req.body.email });
  if (!user) {
    return next(
      new AppError(
        "Il n'y a pas d'utilisateur avec cette adresse e-mail",
        404
      )
    );
  }

  // Generate reset code
  const resetCode = user.createPasswordResetCode();
  await user.save({ validateBeforeSave: false });

  // Send reset code email
  try {
    const message = `Bonjour,\n
    Vous avez oublié votre mot de passe ?\n
    Voici votre code de réinitialisation : ${resetCode}\n
    Ce code est valable pendant 30 minutes.`;

    await sendEmail({
      email: user.email,
      subject:
        "Code de réinitialisation de mot de passe (Valable 30 minutes)",
      message,
    });

    res.status(200).json({
      status: "success",
      message:
        "Votre code de réinitialisation a été envoyé avec succès",
    });
  } catch (err) {
    user.passwordResetCode = undefined;
    user.passwordResetExpires = undefined;
    await user.save({ validateBeforeSave: false });

    return next(
      new AppError(
        "Une erreur s'est produite lors de l'envoi de l'e-mail ! Merci d'essayer plus tard.",
        500
      )
    );
  }
});

// Verify reset code
exports.verifyResetCode = catchAsync(async (req, res, next) => {
  const { email, resetCode } = req.body;

  if (!email || !resetCode) {
    return next(
      new AppError(
        "Veuillez fournir votre email et code de réinitialisation",
        400
      )
    );
  }

  const user = await User.findOne({
    email,
    passwordResetCode: resetCode,
    passwordResetExpires: { $gt: Date.now() },
  });

  if (!user) {
    return next(
      new AppError("Code de réinitialisation invalide ou expiré", 400)
    );
  }

  res.status(200).json({
    status: "success",
    message: "Code de réinitialisation valide",
  });
});

// Reset password
exports.resetPassword = catchAsync(async (req, res, next) => {
  const { email, resetCode, password, passwordConfirm } = req.body;

  if (!email || !resetCode || !password || !passwordConfirm) {
    return next(
      new AppError(
        "Veuillez fournir toutes les informations nécessaires",
        400
      )
    );
  }

  const user = await User.findOne({
    email,
    passwordResetCode: resetCode,
    passwordResetExpires: { $gt: Date.now() },
  });

  if (!user) {
    return next(
      new AppError("Code de réinitialisation invalide ou expiré", 400)
    );
  }

  user.password = password;
  user.passwordConfirm = passwordConfirm;
  user.passwordResetCode = undefined;
  user.passwordResetExpires = undefined;
  await user.save();

  createSendToken(user, 200, res);
});

// Update password
exports.updatePassword = catchAsync(async (req, res, next) => {
  // Get user from collection
  const user = await User.findById(req.user.id).select("+password");

  // Check if current password is correct
  if (
    !(await user.correctPassword(
      req.body.currentPassword,
      user.password
    ))
  ) {
    return next(
      new AppError("Votre mot de passe actuel est incorrect", 401)
    );
  }

  // Update password
  user.password = req.body.password;
  user.passwordConfirm = req.body.passwordConfirm;
  await user.save();

  // Log user in, send JWT
  createSendToken(user, 200, res);
});

// Refresh token
exports.refreshToken = catchAsync(async (req, res, next) => {
  const { refreshToken } = req.body;

  if (!refreshToken) {
    return next(
      new AppError("Aucun jeton de rafraîchissement fourni", 400)
    );
  }

  try {
    const decoded = jwt.verify(
      refreshToken,
      process.env.REFRESH_TOKEN_SECRET
    );
    const user = await User.findById(decoded.id);

    if (!user || user.refreshToken !== refreshToken) {
      return next(
        new AppError("Jeton de rafraîchissement invalide", 401)
      );
    }

    const newAccessToken = signToken(user._id);
    const newRefreshToken = generateRefreshToken(user._id);

    user.refreshToken = newRefreshToken;
    await user.save({ validateBeforeSave: false });

    res.status(200).json({
      status: "success",
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    });
  } catch (err) {
    return next(
      new AppError(
        "Jeton de rafraîchissement invalide ou expiré",
        401
      )
    );
  }
});

// Direct password reset using Firebase Admin
exports.resetPasswordDirect = catchAsync(async (req, res, next) => {
  const { email, newPassword, verificationCode } = req.body;

  if (!email || !newPassword || !verificationCode) {
    return next(
      new AppError(
        "L'email, le nouveau mot de passe et le code de vérification sont requis",
        400
      )
    );
  }

  try {
    console.log(`Password reset request for email: ${email}`);

    // 1. Verify the verification code in Firestore
    const normalizedEmail = email.toLowerCase().trim();
    const collections = ["patients", "medecins", "users"];

    let userData = null;
    let collectionName = null;
    let userId = null;

    // Search for the user in all collections
    for (const collection of collections) {
      console.log(
        `Searching in ${collection} collection for email: ${normalizedEmail}`
      );

      const snapshot = await admin
        .firestore()
        .collection(collection)
        .where("email", "==", normalizedEmail)
        .get();

      if (!snapshot.empty) {
        collectionName = collection;
        userId = snapshot.docs[0].id;
        userData = snapshot.docs[0].data();
        console.log(`User found in ${collection} with ID: ${userId}`);
        break;
      }
    }

    if (!userData) {
      console.log(`User not found for email: ${normalizedEmail}`);
      return next(new AppError("Utilisateur non trouvé", 404));
    }

    // 2. Verify the code
    if (userData.verificationCode !== verificationCode) {
      console.log(
        `Invalid verification code. Expected: ${userData.verificationCode}, Received: ${verificationCode}`
      );
      return next(new AppError("Code de vérification invalide", 400));
    }

    // 3. Check if code is expired
    const validationExpiry =
      userData.validationCodeExpiresAt?.toDate();
    if (!validationExpiry || validationExpiry < new Date()) {
      console.log(
        `Verification code expired. Expiry: ${validationExpiry}, Current: ${new Date()}`
      );
      return next(
        new AppError("Le code de vérification a expiré", 400)
      );
    }

    // 4. Check code type
    const codeType = userData.codeType;
    if (
      codeType !== "motDePasseOublie" &&
      codeType !== "changerMotDePasse"
    ) {
      console.log(`Invalid code type: ${codeType}`);
      return next(
        new AppError(
          "Type de code invalide pour la réinitialisation du mot de passe",
          400
        )
      );
    }

    // 5. Update the password using Firebase Auth Admin
    try {
      console.log(
        `Resetting password for user with email: ${normalizedEmail}`
      );

      // Get user by email and update password
      const userRecord = await admin
        .auth()
        .getUserByEmail(normalizedEmail);
      await admin.auth().updateUser(userRecord.uid, {
        password: newPassword,
      });

      console.log(
        `Password successfully reset for user: ${userRecord.uid}`
      );

      // 6. Clear verification code in Firestore
      await admin
        .firestore()
        .collection(collectionName)
        .doc(userId)
        .update({
          verificationCode: null,
          validationCodeExpiresAt: null,
          codeType: null,
        });

      console.log(`Verification code cleared for user: ${userId}`);

      // 7. Return success response
      res.status(200).json({
        status: "success",
        message: "Mot de passe réinitialisé avec succès",
      });
    } catch (error) {
      console.error(`Error updating password: ${error.message}`);
      return next(
        new AppError(
          `Erreur lors de la réinitialisation du mot de passe: ${error.message}`,
          500
        )
      );
    }
  } catch (error) {
    console.error(`Unexpected error: ${error.message}`);
    return next(
      new AppError("Une erreur inattendue s'est produite", 500)
    );
  }
});
