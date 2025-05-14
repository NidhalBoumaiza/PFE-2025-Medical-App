const catchAsync = require("../utils/catchAsync");
const AppError = require("../utils/appError");
const sendEmail = require("../utils/email");
//-----------------------------------------

//-----------------------------------------

//----------- Sign Up ---------------------

exports.sendMailService = catchAsync(async (req, res, next) => {
  if (!req.body.email || !req.body.subject) {
    return next(
      new AppError(
        "Veuillez saisir votre adresse e-mail et Sujet de l'email",
        400
      )
    );
  }
  if (req.body.subject != "Compte Activer" && !req.body.code) {
    return next(new AppError("Veuillez saisir un code", 400));
  }
  subject = req.body.subject;
  let message = "";
  let code = req.body.code;
  if (subject === "Compte Activer") {
    message = `Bonjour,\n
      Merci de créer un compte a notre platform.\n
      Vore Compte est maintenant activer !`;
  } else if (subject === "Activation de compte") {
    message = `Bonjour,\n
      Merci de créer un compte a notre platform.\n
      Voici le code d'activation de votre compte : ${code}.\n
      Veuillez le saisir pour activer votre compte.`;
  } else if (subject === "Mot de passe oublié") {
    message = `Bonjour,\n
      Merci de créer un compte a notre platform.\n
      Voici le code de réinitialisation de votre mot de passe : ${code.toString}.\n
      Veuillez le saisir pour réinitialiser votre mot de passe.`;
  } else if (subject === "Changer mot de passe") {
    message = `Bonjour,\n
      Voici le code de réinitialisation de votre mot de passe : ${code.toString}.\n
      Veuillez le saisir pour réinitialiser votre mot de passe.`;
  }

  try {
    await sendEmail({
      email: req.body.email,
      subject: req.body.subject || "Activation de compte",
      message,
    });
    res.status(201).json({
      status: "success",
      message: `Un e-mail a été envoyé à ${req.body.email} avec succès`,
    });
  } catch (err) {
    console.log(err);
    return next(
      new AppError(
        "Une erreur s'est produite lors de l'envoi de l'e-mail ! Merci d'essayer plus tard .",
        500
      )
    );
  }
});
