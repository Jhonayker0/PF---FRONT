import React, { createContext, useState, useEffect } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

export const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
  const [state, dispatch] = React.useReducer(
    (prevState, action) => {
      switch (action.type) {
        case 'RESTORE_TOKEN':
          return {
            ...prevState,
            userToken: action.payload.token,
            user: action.payload.user,
            isLoading: false,
          };
        case 'SIGN_IN':
          return {
            ...prevState,
            isSignout: false,
            userToken: action.payload.token,
            user: action.payload.user,
          };
        case 'SIGN_UP':
          return {
            ...prevState,
            isSignout: false,
            userToken: action.payload.token,
            user: action.payload.user,
          };
        case 'SIGN_OUT':
          return {
            ...prevState,
            isSignout: true,
            userToken: null,
            user: null,
          };
      }
    },
    {
      isLoading: true,
      isSignout: false,
      userToken: null,
      user: null,
    }
  );

  useEffect(() => {
    const bootstrapAsync = async () => {
      try {
        const token = await AsyncStorage.getItem('userToken');
        const userStr = await AsyncStorage.getItem('user');
        const user = userStr ? JSON.parse(userStr) : null;

        if (token && user) {
          dispatch({ type: 'RESTORE_TOKEN', payload: { token, user } });
        } else {
          dispatch({ type: 'RESTORE_TOKEN', payload: { token: null, user: null } });
        }
      } catch (e) {
        console.error('Failed to restore token', e);
        dispatch({ type: 'RESTORE_TOKEN', payload: { token: null, user: null } });
      }
    };

    bootstrapAsync();
  }, []);

  const authContext = {
    signIn: async (email, password) => {
      try {
        // Mock authentication - en producción se conectaría a backend
        const mockUser = {
          id: '1',
          email,
          role: email.includes('admin') ? 'admin' : 'client',
          name: email.split('@')[0],
        };
        const mockToken = 'mock_token_' + Date.now();

        await AsyncStorage.setItem('userToken', mockToken);
        await AsyncStorage.setItem('user', JSON.stringify(mockUser));

        dispatch({
          type: 'SIGN_IN',
          payload: { token: mockToken, user: mockUser },
        });

        return { success: true };
      } catch (error) {
        return { success: false, error: error.message };
      }
    },

    signUp: async (email, password, name, role) => {
      try {
        // Mock registration - en producción se conectaría a backend
        const mockUser = {
          id: Date.now().toString(),
          email,
          role: role || 'client',
          name,
        };
        const mockToken = 'mock_token_' + Date.now();

        await AsyncStorage.setItem('userToken', mockToken);
        await AsyncStorage.setItem('user', JSON.stringify(mockUser));

        dispatch({
          type: 'SIGN_UP',
          payload: { token: mockToken, user: mockUser },
        });

        return { success: true };
      } catch (error) {
        return { success: false, error: error.message };
      }
    },

    signOut: async () => {
      try {
        await AsyncStorage.removeItem('userToken');
        await AsyncStorage.removeItem('user');
        dispatch({ type: 'SIGN_OUT' });
      } catch (error) {
        console.error('Error signing out', error);
      }
    },

    state,
  };

  return (
    <AuthContext.Provider value={authContext}>
      {children}
    </AuthContext.Provider>
  );
};
