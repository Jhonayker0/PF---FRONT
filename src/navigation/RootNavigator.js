import React from 'react';
import { NavigationContainer } from '@react-navigation/native';
import { createStackNavigator } from '@react-navigation/stack';

import { AuthContext } from '../context/AuthContext';
import { SplashScreen } from '../screens/SplashScreen';
import { LoginScreen } from '../screens/LoginScreen';
import { RegisterScreen } from '../screens/RegisterScreen';
import { HomeScreen } from '../screens/HomeScreen';
import { CreateEventScreen } from '../screens/CreateEventScreen';
import { EventDetailScreen } from '../screens/EventDetailScreen';
import { EditorialFeedScreen } from '../screens/EditorialFeed/EditorialFeedScreen';

const Stack = createStackNavigator();

const AuthStack = () => {
  return (
    <Stack.Navigator
      screenOptions={{
        headerShown: false,
        animationEnabled: true,
      }}
    >
      <Stack.Screen name="Login" component={LoginScreen} />
      <Stack.Screen 
        name="Register" 
        component={RegisterScreen}
        options={{
          animationEnabled: true,
        }}
      />
    </Stack.Navigator>
  );
};

const AppStack = () => {
  return (
    <Stack.Navigator
      screenOptions={{
        headerShown: false,
        animationEnabled: true,
      }}
    >
      <Stack.Screen 
        name="EditorialFeed" 
        component={EditorialFeedScreen}
        options={{
          animationEnabled: true,
        }}
      />
      <Stack.Screen name="Home" component={HomeScreen} />
      <Stack.Screen 
        name="CreateEvent" 
        component={CreateEventScreen}
        options={{
          animationEnabled: true,
        }}
      />
      <Stack.Screen 
        name="EventDetail" 
        component={EventDetailScreen}
        options={{
          animationEnabled: true,
        }}
      />
    </Stack.Navigator>
  );
};

export const RootNavigator = () => {
  const { state } = React.useContext(AuthContext);

  if (state.isLoading) {
    return (
      <NavigationContainer>
        <Stack.Navigator screenOptions={{ headerShown: false }}>
          <Stack.Screen name="Splash" component={SplashScreen} />
        </Stack.Navigator>
      </NavigationContainer>
    );
  }

  return (
    <NavigationContainer>
      {state.userToken == null ? <AuthStack /> : <AppStack />}
    </NavigationContainer>
  );
};
