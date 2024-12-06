// Import dependencies and model
const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const Trainer = require('./model/product');
require('dotenv').config();

// Create Express app
const app = express();

// Middleware to parse JSON bodies
app.use(express.json());

// Middleware to enable CORS
app.use(cors());

// Connect to MongoDB
const port = process.env.PORT;
const uri = process.env.MONGODB_CONNECTION_STRING;

// Log the collection name
console.log('Collection Name:', Trainer.collection.name);

// Connect to MongoDB
mongoose.connect(uri);

// Get the MongoDB connection instance
const connection = mongoose.connection;

// Event listeners for successful MongoDB connection
connection.once('open', () => {
    console.log('MongoDB database connection established successfully');
    console.log('Connected to DB:', connection.db.databaseName);
});

// Event listeners for unsuccessful MongoDB connection
connection.on('error', () => {
    console.error('MongoDB connection failed');
});

// 1. GET all products
app.get("/allproducts", async (req, res) => {
    try {
      // Fetch all products from the database
        const result = await Trainer.find({});
        // console.log("Trainers from db: ", result); // Log the fetched products
        
        // Send the fetched products as the response
        res.send(result);
      } catch (err) {
        console.error("Error fetching products: ", err);
        
        // Send a 500 response if an error occurs
        res.status(500).send("Internal Server Error");
      }
});

// 2. GET API Health Check
app.get("/api/health", (req, res) => {
  res.status(200).send("OK");
});

// 3. GET a product by product code
app.get("/product/:product_code", async (req, res) => {
  try {
    // Extract the product code from the request parameters
      const productCode = req.params.product_code;

      // Find the product by product code
      const product = await Trainer.findOne({ "trainers.product_code": productCode });
      // console.log(`Query result: ${product}`); // Log the query result

      if (!product) {
        // Send a 404 response if the product is not found
          return res.status(404).send("Product not found");
      }

      // Send the found product as the response
      res.send(product); // Make sure to send the product data properly
  } catch (err) {
      console.error("Error fetching product: ", err);
      
      // Send a 500 response if an error occurs
      res.status(500).send("Internal Server Error");
  }
});

// 4. POST to add a new product
app.post("/product", async (req, res) => {
  try {
    // Create a new product instance with the request body
      const newProduct = new Trainer(req.body);
      
      // Save the new product to the database
      const savedProduct = await newProduct.save();
      console.log("Product added: ", savedProduct);
      
      // Send the saved product as the response with a 201 status
      res.status(201).send(savedProduct);
  } catch (err) {
      console.error("Error adding product: ", err);
      
      // Send a 500 response if an error occurs
      res.status(500).send("Internal Server Error");
  }
});

// 5. PUT to update a product by product code
app.put("/product/:product_code", async (req, res) => {
  try {
    // Extract the product code from the request parameters
      const productCode = req.params.product_code;
      
      // Find the product by product code and update it with the request body
      const updatedProduct = await Trainer.findOneAndUpdate(
          { product_code: productCode }, // Filter to find the product
          req.body,                     // Data to update the product with
          { new: true, runValidators: true } // Options: return the updated document and run validators
      );
      if (!updatedProduct) {
        
        // Send a 404 response if the product is not found
          return res.status(404).send("Product not found");
      }
      console.log("Product updated: ", updatedProduct);
      
      // Send the updated product as the response
      res.send(updatedProduct);
  } catch (err) {
      console.error("Error updating product: ", err);
      
      // Send a 500 response if an error occurs
      res.status(500).send("Internal Server Error");
  }
});

// 6. DELETE a product by product code
app.delete("/product/:product_code", async (req, res) => {
  try {
    // Extract the product code from the request parameters
      const productCode = req.params.product_code;
      
      // Find the product by product code and delete it
      const deletedProduct = await Trainer.findOneAndDelete({ product_code: productCode });
      if (!deletedProduct) {
        // Send a 404 response if the product is not found
          return res.status(404).send("Product not found");
      }
      console.log("Product deleted: ", deletedProduct);
      
      // Send the deleted product as the response
      res.send(deletedProduct);
  } catch (err) {
      console.error("Error deleting product: ", err);
      
      // Send a 500 response if an error occurs
      res.status(500).send("Internal Server Error");
  }
});

// Start the server and listen on the specified port
app.listen(port, () => {
  console.log(`Server is listening at http://localhost:${port}`);
});

module.exports = app; // This aims to export the app object for testing purposes (DO NOT REMOVE!)