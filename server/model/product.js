const mongoose = require('mongoose');
const Schema = mongoose.Schema;

const trainerSchema = new Schema({
    product_code: {
        type: String,
        required: true,
        unique: true
    },
    product_name: {
        type: String,
        required: true
    },
    price: {
        type: String,
        required: true
    },
    color: {
        type: String,
        required: true
    },
    exclusivity: {
        type: String,
        required: true
    },
    upper_material: {
        type: String,
        required: true
    },
    sole_material: {
        type: String,
        required: true
    },
    midsole: {
        type: String,
        required: true
    },
    outsole: {
        type: String,
        required: true
    },
    closure_type: {
        type: String,
        required: true
    },
    fit_features: {
        type: String,
        required: true
    },
    comfort_features: {
        type: String,
        required: true
    },
    branding: {
        type: String,
        required: true
    },
    availability_at_store: {
        type: String,
        required: true
    },
    sales_exclusive_design: {
        type: String,
        required: true
    },
    sales_upper_material: {
        type: String,
        required: true
    },
    sales_midsole: {
        type: String,
        required: true
    },
    sales_outsole: {
        type: String,
        required: true
    },
    sales_closure_type: {
        type: String,
        required: true
    },
    sales_branding: {
        type: String,
        required: true
    },
    sales_versatile_styling: {
        type: String,
        required: true
    },
    sales_materials: {
        type: String,
        required: true
    },
    sales_comfort_features: {
        type: String,
        required: true
    },
    image_URL: {
        type: String,
        required: true
    }
});

const Trainer = mongoose.model('Trainer', trainerSchema, 'trainers');

module.exports = Trainer;