import React, { ComponentType, useCallback, useState } from 'react';
import { View, TouchableOpacity, Text, StyleSheet } from 'react-native';
import Animated, {
  interpolate,
  SharedValue,
  useAnimatedStyle,
} from 'react-native-reanimated';
import { Categories } from './Categories';
import { EditorialCategory, EditorialCategoryData } from './data/categories';
import { Gradient } from './Gradient';
import { ProfileBottomSheet } from './ProfileBottomSheet';

export const HEADER_HEIGHT = 45;
const GRADIENT_HEIGHT = 35;

type Props = {
  scrollY: SharedValue<number>;
  onCategoryChanged: (categoryTitle: EditorialCategory['title']) => void;
};

export const Header: ComponentType<Props> = ({
  scrollY,
  onCategoryChanged,
}) => {
  const [selectedCategory, setSelectedCategory] = useState<
    EditorialCategory['title']
  >(EditorialCategoryData[0].title);
  const [profileBottomSheetVisible, setProfileBottomSheetVisible] =
    useState(false);
  const topOffset = 20; // Default safe area top
  const headerHeight = HEADER_HEIGHT + topOffset;

  const containerAnimatedStyle = useAnimatedStyle(() => ({
    transform: [
      {
        translateY: interpolate(
          scrollY.value,
          [-1, 0, HEADER_HEIGHT, HEADER_HEIGHT - 1],
          [0, 0, -HEADER_HEIGHT, -HEADER_HEIGHT],
        ),
      },
    ],
  }));

  const logoAnimatedStyle = useAnimatedStyle(() => ({
    opacity: interpolate(scrollY.value, [0, topOffset], [1, 0]),
  }));

  const gradientAnimatedStyle = useAnimatedStyle(() => ({
    opacity: interpolate(
      scrollY.value,
      [
        0,
        topOffset,
        topOffset + GRADIENT_HEIGHT + 10,
        topOffset + GRADIENT_HEIGHT + 11,
      ],
      [0, 0, 1, 1],
    ),
  }));

  const handleCategoryChanged = useCallback(
    (categoryTitle: EditorialCategory['title']) => {
      setSelectedCategory(categoryTitle);
      onCategoryChanged(categoryTitle);
    },
    [onCategoryChanged],
  );

  return (
    <>
      <Animated.View style={[styles.container, containerAnimatedStyle]}>
        <View style={[styles.headerContainer, { height: headerHeight }]}>
          <Animated.View style={[styles.headerBar, logoAnimatedStyle]}>
            <View style={styles.logoContainer}>
              <Text style={styles.logoText}>Discover</Text>
            </View>
            <View style={styles.navigationButton}>
              <TouchableOpacity
                onPress={() => setProfileBottomSheetVisible(true)}
                style={styles.userButton}
              >
                <Text style={styles.userIcon}>👤</Text>
              </TouchableOpacity>
            </View>
          </Animated.View>
        </View>
        <View style={styles.categoriesContainer}>
          <Categories
            onPress={handleCategoryChanged}
            selectedCategoryTitle={selectedCategory}
          />
        </View>
        <Animated.View style={gradientAnimatedStyle}>
          <Gradient height={GRADIENT_HEIGHT} />
        </Animated.View>
      </Animated.View>
      <ProfileBottomSheet
        visible={profileBottomSheetVisible}
        onRequestClose={() => setProfileBottomSheetVisible(false)}
      />
    </>
  );
};

const styles = StyleSheet.create({
  container: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    zIndex: 1,
  },
  headerContainer: {
    backgroundColor: '#fff',
    justifyContent: 'flex-end',
    paddingBottom: 12,
  },
  headerBar: {
    marginHorizontal: 16,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  logoContainer: {
    alignItems: 'center',
    justifyContent: 'center',
    flex: 1,
  },
  logoText: {
    fontSize: 20,
    fontWeight: 'bold',
    color: '#1a1a1a',
  },
  navigationButton: {
    position: 'absolute',
    right: 0,
  },
  userButton: {
    width: 40,
    height: 40,
    borderRadius: 20,
    backgroundColor: '#f5f5f5',
    justifyContent: 'center',
    alignItems: 'center',
  },
  userIcon: {
    fontSize: 20,
  },
  categoriesContainer: {
    backgroundColor: '#fff',
    borderBottomColor: '#e0e0e0',
    borderBottomWidth: 1,
  },
});