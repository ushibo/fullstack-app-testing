import { useState } from 'react'
import './App.css'
import BackendStatus from './components/BackendStatus'

function App() {
  const [count, setCount] = useState(0)

  return (
    <>
      <BackendStatus />
      <div className="card">
        <button onClick={() => setCount((count) => count + 1)}>
          count is {count}
        </button>
      </div>
      <p className="read-the-docs">
        Click on the Vite and React logos to learn more
      </p>
    </>
  )
}

export default App
