const User = require('../models/User');

// GET /api/employees  – employees that belong to this NGO
const getEmployees = async (req, res) => {
  try {
    const employees = await User.find({
      role: 'Employee',
      'employeeDetails.ngoId': req.user._id,
    }).select('-password');
    return res.json(employees);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

// POST /api/employees  – NGO adds a new employee
const addEmployee = async (req, res) => {
  try {
    const { name, email, mobile, password } = req.body;
    if (!name || !email || !password) {
      return res.status(400).json({ message: 'Name, email and password are required.' });
    }

    const exists = await User.findOne({ email: email.toLowerCase() });
    if (exists) {
      return res.status(409).json({ message: 'Email already in use.' });
    }

    const employee = await User.create({
      email: email.toLowerCase(),
      password,
      role: 'Employee',
      employeeDetails: {
        name,
        mobile: mobile || '',
        ngoId: req.user._id,
      },
    });

    return res.status(201).json({
      _id: employee._id,
      email: employee.email,
      role: employee.role,
      employeeDetails: employee.employeeDetails,
    });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
};

module.exports = { getEmployees, addEmployee };
