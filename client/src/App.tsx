import { Route, Routes } from "react-router-dom";
import PATH from "@/constants/path.ts";

const App = () => {
  return (
    <>
      <Routes>
        <Route path={PATH.HOME} element={<></>} />
      </Routes>
    </>
  );
};

export default App;
