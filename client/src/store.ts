import { configureStore } from "@reduxjs/toolkit";

// Import reducers
import AuthFeature from "./features/auth";

export const store = configureStore({
  reducer: {
    auth: AuthFeature.slice.reducer,
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
