import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';

function Error() {
  const [productCode, setProductCode] = useState('')
  const navigate = useNavigate();

  const handleGo = () => {
    if (productCode.trim()) {
      navigate(`/product/${productCode}`);
    }
  };

  return (
    <div className="product-container">
      <Link to="/">
        <img src="/logo.png" alt="JD Sports Logo" className="logo1" />
      </Link>

      <h1>Product Not Found</h1>
      <p>Please check the product code you entered and try again.</p>

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

export default Error;
