import React from 'react';
import { useParams, Link } from 'react-router-dom';
import './Product.css';

function Product() {
    const { code } = useParams(); // This can be removed if not used
  
    // Hardcoded data for demonstration purposes
    const product = {
      name: 'Nike Air Max 95',
      price: '£175',
      image: `${process.env.PUBLIC_URL}/images/nike.png`, // Reference the image
      specifications: {
        Color: 'Iron Grey with Baltic Blue accents',
        Exclusivity: 'Only At JD',
        'Upper Material': 'Mesh, Leather, Textile, Synthetics',
        'Sole Material': 'Synthetic Sole',
        Midsole: 'Lightweight foam with Max Air cushioning',
        Outsole: 'Tough rubber for traction',
        'Closure Type': 'Lace-up fastening',
        'Fit Features': 'Padded ankle collar for a locked-in fit',
        'Comfort Features': 'Max Air cushioning for unbeatable comfort',
        Branding: 'Signature Swoosh and Air Max branding',
        'Available at store': 'Yes',
      },
      salesPitch: {
        Feature: [
          "Exclusive Design",
          "Upper Material",
          "Midsole",
          "Outsole",
          "Closure Type",
          "Branding",
          "Versatile Styling",
          "Materials",
          "Comfort Features"
        ],
        Benefit: [
          "This limited-edition colorway is exclusive to JD, making your pair unique and sure to stand out.",
          "The combination of premium materials ensures long-lasting durability while keeping your feet cool.",
          "Enjoy the iconic Max Air cushioning technology that provides unbeatable comfort and reduces foot fatigue.",
          "No need to worry about slipping – the tough rubber outsole offers incredible grip on any surface.",
          "The lace-up fastening and padded collar provide a secure fit, locking your foot in place for maximum support.",
          "Show off the classic Nike look with the signature Swoosh and Air Max branding – a symbol of quality and style.",
          "A versatile design that works with anything – from casual wear to a sporty look. Perfect for every occasion.",
          "The mix of leather, textile, and synthetics gives you a luxurious feel without compromising durability.",
          "The Max Air cushioning technology will keep you comfortable throughout the day, no matter where you go."
        ]
      }
    };

    return (
        <div className="product-container">
          <Link to="/">
            <img src="/logo.png" alt="JD Sports Logo" className="logo1" />
          </Link>
    
          <div className="input-container">
            <input type="text" placeholder="Enter product code" />
            <button>Go</button>
          </div>
    
          <div className="product-image">
            <img src={product.image} alt={product.name} />
          </div>
    
          <div className="name-price-container">
            <h1>{product.name}</h1>
            <p className="price">{product.price}</p>
          </div>
    
          {/* Product Specifications */}
          <div className="specifications">
            <h2>Product Specifications:</h2>
            <table>
              <thead>
                <tr>
                  <th>Specification</th>
                  <th>Details</th>
                </tr>
              </thead>
              <tbody>
                {Object.entries(product.specifications).map(([key, value]) => (
                  <tr key={key}>
                    <td>{key}</td>
                    <td>{value}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
    
          {/* New Sales Pitch Table */}
          <div className="sales-pitch">
            <h2>Sales Pitch:</h2>
            <table>
              <thead>
                <tr>
                  <th>Feature</th>
                  <th>Customer Benefit</th>
                </tr>
              </thead>
              <tbody>
                {product.salesPitch.Feature.map((feature, index) => (
                  <tr key={index}>
                    <td className="feature">{feature}</td>
                    <td className="customer-benefit">{product.salesPitch.Benefit[index]}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      );
    }
    
    export default Product;