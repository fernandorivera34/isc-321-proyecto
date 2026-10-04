import { StrictMode, useEffect } from "react";
import { Provider, useDispatch } from "react-redux";
import { AppDispatch } from "./store";
import { RouterProvider, createRouter } from "@tanstack/react-router";

import { store } from "./store";
import { routeTree } from "./routeTree.gen";
// import Route404 from "./routes/errors/404";
import { Context } from "./Context";

const router = createRouter({
  routeTree,
  // defaultNotFoundComponent: () => <Route404 />,
});

declare module "@tanstack/react-router" {
  interface Register {
    router: typeof router;
  }
}

// Component to dispatch config fetch on app start
const AppInitializer = ({ children }: { children: React.ReactNode }) => {
  const dispatch = useDispatch<AppDispatch>();

  return <>{children}</>;
};

const App = () => (
  <StrictMode>
    <Context.Provider value={{ name: "App" }}>
      <Provider store={store}>
        <AppInitializer>
          <RouterProvider router={router} />
        </AppInitializer>
      </Provider>
    </Context.Provider>
  </StrictMode>
);

export default App;
