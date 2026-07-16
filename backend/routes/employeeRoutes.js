const express = require('express');
const router = express.Router();
const { getEmployees, addEmployee } = require('../controllers/employeeController');
const { protect } = require('../middleware/authMiddleware');

router.get('/', protect, getEmployees);
router.post('/', protect, addEmployee);

module.exports = router;
