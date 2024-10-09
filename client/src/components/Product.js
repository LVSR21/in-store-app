import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useParams, Link } from 'react-router-dom';
import axios from 'axios';
import './Product.css';

function Product() {
  const [productCode, setProductCode] = useState('');
  const navigate = useNavigate();
  const { product_code } = useParams();
  const [product, setProduct] = useState(null);
  

  // Fetch the product by product code
  useEffect(() => {
    const fetchProduct = async () => {
      if (product_code) {
        try {
          const response = await axios.get(`http://localhost:5000/product/${product_code}`);
          if (response.data && response.data.trainers) {
            setProduct(response.data.trainers);
          } else {
            navigate('/error'); // Redirect to Error page if product not found
          }
        } catch (error) {
          // Redirect to error page on error
          if (error.response && error.response.status === 404) {
            navigate('/error'); // Redirect to Error page if product not found
          } else {
            console.error("Error fetching product: ", error);
            navigate('/error'); // Redirect for any other error
          }
        }
      }
    };

    fetchProduct();
  }, [product_code, navigate]);

  const handleGo = async () => {
    if (productCode.trim()) {
      try {
        const response = await axios.get(`http://localhost:5000/product/${productCode}`);
        if (response.data && response.data.trainers) {
          navigate(`/product/${productCode}`);
        } else {
          navigate('/error'); // Redirect to Error page if product code is not found
        }
      } catch (error) {
        if (error.response && error.response.status === 404) {
          navigate('/error'); // Redirect to Error page if product code not found
        } else {
          console.error("Error fetching product:", error);
        }
      }
    }
  };

  if (!product) {
    return <div>Loading...</div>;
  }

  // Render the product details if available
  return (
    <div className="product-container">
      <Link to="/">
        <img src="/logo.png" alt="JD Sports Logo" className="logo1" />
      </Link>

      <div className="input-container">
        <input 
          type="text" 
          placeholder="Product-code"
          value={productCode}
          onChange={(e) => setProductCode(e.target.value)}
        />
        <button onClick={handleGo}>Go</button>
      </div>

      <div className="product-image">
        <img src={product.image_URL} alt={product.product_name} />
      </div>

      <div className="name-price-container">
        <h1>{product.product_name}</h1>
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
            <tr>
              <td>Color</td>
              <td>{product.color}</td>
            </tr>
            <tr>
              <td>Exclusivity</td>
              <td>{product.exclusivity}</td>
            </tr>
            <tr>
              <td>Upper Material</td>
              <td>{product.upper_material}</td>
            </tr>
            <tr>
              <td>Sole Material</td>
              <td>{product.sole_material}</td>
            </tr>
            <tr>
              <td>Midsole</td>
              <td>{product.midsole}</td>
            </tr>
            <tr>
              <td>Outsole</td>
              <td>{product.outsole}</td>
            </tr>
            <tr>
              <td>Closure Type</td>
              <td>{product.closure_type}</td>
            </tr>
            <tr>
              <td>Fit Features</td>
              <td>{product.fit_features}</td>
            </tr>
            <tr>
              <td>Comfort Features</td>
              <td>{product.comfort_features}</td>
            </tr>
            <tr>
              <td>Branding</td>
              <td>{product.branding}</td>
            </tr>
            <tr>
              <td>Available at store</td>
              <td>{product.available_at_store}</td>
            </tr>
          </tbody>
        </table>
      </div>

      {/* Sales Pitch */}
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
            <tr>
              <td>Exclusive Design</td>
              <td>{product.sales_exclusive_design}</td>
            </tr>
            <tr>
              <td>Upper Material</td>
              <td>{product.sales_upper_material}</td>
            </tr>
            <tr>
              <td>Midsole</td>
              <td>{product.sales_midsole}</td>
            </tr>
            <tr>
              <td>Outsole</td>
              <td>{product.sales_outsole}</td>
            </tr>
            <tr>
              <td>Closure Type</td>
              <td>{product.sales_closure_type}</td>
            </tr>
            <tr>
              <td>Branding</td>
              <td>{product.sales_branding}</td>
            </tr>
            <tr>
              <td>Versatile Styling</td>
              <td>{product.sales_versatile_styling}</td>
            </tr>
            <tr>
              <td>Materials</td>
              <td>{product.sales_materials}</td>
            </tr>
            <tr>
              <td>Comfort Features</td>
              <td>{product.sales_comfort_features}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  );
}

export default Product;
