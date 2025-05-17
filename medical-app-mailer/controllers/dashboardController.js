const Appointment = require("../models/appointmentModel");
const User = require("../models/userModel");
const DashboardStats = require("../models/dashboardStatsModel");
const catchAsync = require("../utils/catchAsync");
const AppError = require("../utils/appError");

// Get upcoming appointments for a doctor
exports.getUpcomingAppointments = catchAsync(
  async (req, res, next) => {
    const { limit = 5 } = req.query;
    const doctorId = req.params.doctorId || req.user.id;

    // Verify doctor exists
    const doctor = await User.findOne({
      _id: doctorId,
      role: "medecin",
    });
    if (!doctor) {
      return next(new AppError("Médecin non trouvé", 404));
    }

    const now = new Date();

    // Find appointments for this doctor that are in the future and not cancelled
    const appointments = await Appointment.find({
      medecin: doctorId,
      status: { $ne: "cancelled" },
      startDate: { $gte: now },
    })
      .sort({ startDate: 1 })
      .limit(parseInt(limit))
      .populate({
        path: "patient",
        select: "name lastName",
      });

    res.status(200).json({
      status: "success",
      results: appointments.length,
      data: {
        appointments,
      },
    });
  }
);

// Count appointments by status for a doctor
exports.getAppointmentsCountByStatus = catchAsync(
  async (req, res, next) => {
    const doctorId = req.params.doctorId || req.user.id;

    // Verify doctor exists
    const doctor = await User.findOne({
      _id: doctorId,
      role: "medecin",
    });
    if (!doctor) {
      return next(new AppError("Médecin non trouvé", 404));
    }

    // Get counts for each status
    const total = await Appointment.countDocuments({
      medecin: doctorId,
    });
    const pending = await Appointment.countDocuments({
      medecin: doctorId,
      status: "pending",
    });
    const accepted = await Appointment.countDocuments({
      medecin: doctorId,
      status: "accepted",
    });
    const cancelled = await Appointment.countDocuments({
      medecin: doctorId,
      status: "cancelled",
    });
    const completed = await Appointment.countDocuments({
      medecin: doctorId,
      status: "completed",
    });

    res.status(200).json({
      status: "success",
      data: {
        total,
        pending,
        accepted,
        cancelled,
        completed,
      },
    });
  }
);

// Count total patients for a doctor
exports.getTotalPatientsCount = catchAsync(async (req, res, next) => {
  const doctorId = req.params.doctorId || req.user.id;

  // Verify doctor exists
  const doctor = await User.findOne({
    _id: doctorId,
    role: "medecin",
  });
  if (!doctor) {
    return next(new AppError("Médecin non trouvé", 404));
  }

  // Get unique patients who have appointments with this doctor
  const uniquePatients = await Appointment.distinct("patient", {
    medecin: doctorId,
  });

  res.status(200).json({
    status: "success",
    data: {
      totalPatients: uniquePatients.length,
    },
  });
});

// Get complete dashboard statistics for a doctor
exports.getDoctorDashboardStats = catchAsync(
  async (req, res, next) => {
    const doctorId = req.params.doctorId || req.user.id;

    // Verify doctor exists
    const doctor = await User.findOne({
      _id: doctorId,
      role: "medecin",
    });
    if (!doctor) {
      return next(new AppError("Médecin non trouvé", 404));
    }

    const now = new Date();

    // Get appointment counts
    const appointmentCounts = {
      total: await Appointment.countDocuments({ medecin: doctorId }),
      pending: await Appointment.countDocuments({
        medecin: doctorId,
        status: "pending",
      }),
      accepted: await Appointment.countDocuments({
        medecin: doctorId,
        status: "accepted",
      }),
      cancelled: await Appointment.countDocuments({
        medecin: doctorId,
        status: "cancelled",
      }),
      completed: await Appointment.countDocuments({
        medecin: doctorId,
        status: "completed",
      }),
    };

    // Get unique patients
    const uniquePatients = await Appointment.distinct("patient", {
      medecin: doctorId,
    });

    // Get upcoming appointments
    const upcomingAppointments = await Appointment.find({
      medecin: doctorId,
      status: { $ne: "cancelled" },
      startDate: { $gte: now },
    })
      .sort({ startDate: 1 })
      .limit(5)
      .populate({
        path: "patient",
        select: "name lastName",
      });

    // Create or update dashboard stats
    const dashboardStats = {
      medecin: doctorId,
      date: now,
      totalPatients: uniquePatients.length,
      totalAppointments: appointmentCounts.total,
      pendingAppointments: appointmentCounts.pending,
      completedAppointments: appointmentCounts.completed,
      cancelledAppointments: appointmentCounts.cancelled,
      upcomingAppointments: upcomingAppointments.map(
        (app) => app._id
      ),
    };

    // Save stats to database for historical tracking
    await DashboardStats.findOneAndUpdate(
      {
        medecin: doctorId,
        date: {
          $gte: new Date(now.setHours(0, 0, 0, 0)),
          $lt: new Date(now.setHours(23, 59, 59, 999)),
        },
      },
      dashboardStats,
      { upsert: true, new: true }
    );

    res.status(200).json({
      status: "success",
      data: {
        totalPatients: uniquePatients.length,
        totalAppointments: appointmentCounts.total,
        pendingAppointments: appointmentCounts.pending,
        completedAppointments: appointmentCounts.completed,
        cancelledAppointments: appointmentCounts.cancelled,
        upcomingAppointments,
      },
    });
  }
);

// Get doctor's patients with pagination
exports.getDoctorPatients = catchAsync(async (req, res, next) => {
  const doctorId = req.params.doctorId || req.user.id;
  const { limit = 10, lastPatientId } = req.query;

  // Verify doctor exists
  const doctor = await User.findOne({
    _id: doctorId,
    role: "medecin",
  });
  if (!doctor) {
    return next(new AppError("Médecin non trouvé", 404));
  }

  // Get all appointments for this doctor
  let query = Appointment.find({ medecin: doctorId });

  // Apply pagination if lastPatientId is provided
  if (lastPatientId) {
    const lastAppointment = await Appointment.findById(lastPatientId);
    if (lastAppointment) {
      query = query.gt("_id", lastAppointment._id);
    }
  }

  const appointments = await query.limit(parseInt(limit)).populate({
    path: "patient",
    select: "name lastName email phoneNumber",
  });

  // Extract unique patients from appointments
  const patientsMap = new Map();
  appointments.forEach((appointment) => {
    if (
      appointment.patient &&
      !patientsMap.has(appointment.patient._id.toString())
    ) {
      const patientData = {
        id: appointment.patient._id,
        name: appointment.patient.name,
        lastName: appointment.patient.lastName,
        email: appointment.patient.email,
        phoneNumber: appointment.patient.phoneNumber || "",
        lastAppointment: appointment.startDate,
        lastAppointmentStatus: appointment.status,
      };
      patientsMap.set(
        appointment.patient._id.toString(),
        patientData
      );
    }
  });

  const patients = Array.from(patientsMap.values());

  // Sort by most recent appointment
  patients.sort(
    (a, b) =>
      new Date(b.lastAppointment) - new Date(a.lastAppointment)
  );

  // Determine if there are more patients to load
  const hasMore = appointments.length >= parseInt(limit);
  const nextPatientId =
    hasMore && appointments.length > 0
      ? appointments[appointments.length - 1]._id
      : null;

  res.status(200).json({
    status: "success",
    data: {
      patients,
      hasMore,
      nextPatientId,
    },
  });
});
