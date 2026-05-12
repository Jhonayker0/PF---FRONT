import React, {
  useCallback,
  useMemo,
  useRef,
  useState,
} from 'react';
import { View, StyleSheet } from 'react-native';
import { useSharedValue } from 'react-native-reanimated';
import { Card } from './Card';
import { CATEGORY_ITEM_HEIGHT } from './Categories';
import { editorialArticlesData } from './data/articles';
import { EditorialCategoryData } from './data/categories';
import { Header, HEADER_HEIGHT } from './Header';
import { VerticalCarousel } from './VerticalCarousel';
import type { ComponentType } from 'react';
import type { ListRenderItemInfo } from 'react-native';
import type { SharedValue } from 'react-native-reanimated';
import type { EditorialArticleItem } from './data/articles';
import type { EditorialCategory } from './data/categories';
import type { VerticalCarouselHandle } from './VerticalCarousel';

type Props = {
  onPressArticle?: (id: string) => () => void;
};

export const EditorialFeedScreen: ComponentType<Props> = ({
  onPressArticle = (id: string) => () => console.log('Article pressed:', id),
}) => {
  const scrollY = useSharedValue(0);
  const carouselRef = useRef<VerticalCarouselHandle>(null);
  const [selectedCategory, setSelectedCategory] = useState<
    EditorialCategory['title']
  >(EditorialCategoryData[0]?.title ?? 'All');

  const filteredPostsData = useMemo(
    () =>
      editorialArticlesData.filter(item =>
        item.categories.includes(selectedCategory),
      ),
    [selectedCategory],
  );

  const handlePressCategory = useCallback(
    (categoryTitle: EditorialCategory['title']) => {
      carouselRef.current?.scrollToTop();
      setSelectedCategory(categoryTitle);
    },
    [],
  );

  const handleScroll = (sharedValue: SharedValue<number>) => {
    'worklet';
    scrollY.value = sharedValue.value;
  };

  const renderCardItem = useCallback(
    ({ item }: ListRenderItemInfo<EditorialArticleItem>) => (
      <Card item={item} onPress={onPressArticle(item.id)} />
    ),
    [onPressArticle],
  );

  return (
    <View style={styles.container}>
      <Header scrollY={scrollY} onCategoryChanged={handlePressCategory} />
      <View style={styles.carouselContainer}>
        <VerticalCarousel<EditorialArticleItem>
          ref={carouselRef}
          offsetTop={
            HEADER_HEIGHT +
            CATEGORY_ITEM_HEIGHT +
            10 +
            20
          }
          data={filteredPostsData}
          renderItem={renderCardItem}
          onScroll={handleScroll}
        />
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
  },
  carouselContainer: {
    minHeight: 0,
    paddingHorizontal: 16,
    height: 800,
  },
});
