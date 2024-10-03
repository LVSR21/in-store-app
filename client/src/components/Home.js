import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import './Home.css';

function Home() {
  const [productCode, setProductCode] = useState('');
  const navigate = useNavigate();

  const handleGo = () => {
    if (productCode.trim()) {
      navigate(`/product/${productCode}`);
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
    </div>
  );
}

export default Home;
