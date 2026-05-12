import { Text } from 'react-native';
import React, { ComponentType, useCallback, useRef } from 'react';
import { FlatList, Pressable, View, StyleSheet } from 'react-native';
import { EditorialCategory, EditorialCategoryData } from './data/categories';

export const CATEGORY_ITEM_HEIGHT = 40;

type CategoryItemProps = EditorialCategory & {
  selected: boolean;
  onPress: () => void;
};

export const CategoryItem = ({
  title,
  selected,
  onPress,
}: CategoryItemProps) => {
  return (
    <View
      style={[
        categoryItemStyles.container,
        selected && categoryItemStyles.selectedContainer,
      ]}
    >
      <Pressable
        onPress={onPress}
        hitSlop={4}
        style={categoryItemStyles.touchable}
      >
        <View style={categoryItemStyles.contentContainer}>
          <Text
            style={[
              categoryItemStyles.categoryText,
              selected && categoryItemStyles.selectedText,
            ]}
          >
            {title}
          </Text>
        </View>
      </Pressable>
    </View>
  );
};

const categoryItemStyles = StyleSheet.create({
  container: {
    height: CATEGORY_ITEM_HEIGHT,
    marginHorizontal: 4,
    paddingHorizontal: 8,
    borderBottomWidth: 2,
    borderBottomColor: 'transparent',
  },
  selectedContainer: {
    borderBottomColor: '#6C63FF',
  },
  touchable: {
    height: CATEGORY_ITEM_HEIGHT,
  },
  contentContainer: {
    height: CATEGORY_ITEM_HEIGHT,
    justifyContent: 'flex-end',
    paddingBottom: 8,
    gap: 4,
  },
  categoryText: {
    fontSize: 14,
    color: '#999',
  },
  selectedText: {
    color: '#6C63FF',
    fontWeight: '600',
  },
});

type Props = {
  selectedCategoryTitle: EditorialCategory['title'];
  onPress: (categoryTitle: EditorialCategory['title']) => void;
};

export const Categories: ComponentType<Props> = ({
  onPress,
  selectedCategoryTitle,
}) => {
  const flatListRef = useRef<FlatList<EditorialCategory>>(null);

  const handlePressCategory = useCallback(
    ({ item, index }: { item: EditorialCategory; index: number }) =>
      () => {
        onPress(item.title);
        if (flatListRef.current) {
          flatListRef.current.scrollToIndex({
            index,
            animated: true,
          });
        }
      },
    [onPress],
  );

  return (
    <FlatList<EditorialCategory>
      ref={flatListRef}
      data={EditorialCategoryData}
      horizontal
      renderItem={({ item, index }) => (
        <CategoryItem
          {...item}
          selected={item.title === selectedCategoryTitle}
          onPress={handlePressCategory({ item, index })}
        />
      )}
      showsHorizontalScrollIndicator={false}
      keyExtractor={item => item.title.toString()}
      style={categoriesStyles.list}
      contentContainerStyle={categoriesStyles.contentContainer}
      decelerationRate="fast"
    />
  );
};

const categoriesStyles = StyleSheet.create({
  list: {
    paddingHorizontal: 16,
  },
  contentContainer: {
    paddingRight: 32,
  },
});
