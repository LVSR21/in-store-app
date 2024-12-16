import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import axios from 'axios';
import './Home.css';

function Home() {
  const [productCode, setProductCode] = useState('');
  const [errorMessages, setErrorMessages] = useState('');
  const navigate = useNavigate();

  const handleGo = async () => {
    setErrorMessages('');
    if (productCode.trim()) {
      try {
        // Make a request to check if the product exists
        const response = await axios.get(`/api/product/${productCode}`);
        
        if (response.data) {
          // If the product exists, navigate to the product page
          navigate(`/product/${productCode}`);
        }
      } catch (error) {
        // Handle error (e.g., product not found)
        if (error.response && error.response.status === 404) {
          setErrorMessages('Product code not found. Please try again.');
        } else {
          console.error("Error fetching product:", error);
        }
      }
    }
  };

  return (
    <div className="home-container">
      <img src="/logo.png" alt="JD Sports Logo" className="logo" />
      <h1>
        <span>Welcome to</span>
        <br />
        <span>
          JD Sports <span className="yellow-text">in-store app</span>
        </span>
      </h1>
      <div className="input-container">
        <input
          type="text"
          placeholder="Product-code"
          value={productCode}
          onChange={(e) => setProductCode(e.target.value)}
        />
        <button onClick={handleGo}>Go</button>
      </div>
      {errorMessages && <p className="error-message">{errorMessages}</p>}
    </div>
  );
}

export default Home;