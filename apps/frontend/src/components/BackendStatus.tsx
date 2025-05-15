import { useState, useEffect } from 'react';
import './BackendStatus.css';

interface BackendHealthResponse {
  status: string;
  timestamp: string;
}

const BackendStatus = () => {
  const [status, setStatus] = useState<'online' | 'offline' | 'loading'>('loading');
  const [lastCheck, setLastCheck] = useState<string | null>(null);

  const checkBackendHealth = async () => {
    try {
      const response = await fetch('/api/health');
      const data: BackendHealthResponse = await response.json();
      
      if (data.status === 'ok') {
        setStatus('online');
        setLastCheck(new Date(data.timestamp).toLocaleTimeString());
      } else {
        setStatus('offline');
      }
    } catch (error) {
      console.error('Error checking backend health:', error);
      setStatus('offline');
    }
  };

  useEffect(() => {
    // Check immediately on component mount
    checkBackendHealth();
    
    // Set up interval to check every 5 seconds
    const intervalId = setInterval(checkBackendHealth, 5000);
    
    // Clean up interval on component unmount
    return () => clearInterval(intervalId);
  }, []);

  return (
    <div className="backend-status-container">
      <div className={`backend-status ${status}`}>
        <div className="pulse"></div>
        <div className="status-text">
          Backend {status === 'online' ? 'Online' : status === 'offline' ? 'Offline' : 'Connecting...'}
        </div>
      </div>
      {lastCheck && status === 'online' && (
        <div className="last-check">
          Last check: {lastCheck}
        </div>
      )}
    </div>
  );
};

export default BackendStatus; 