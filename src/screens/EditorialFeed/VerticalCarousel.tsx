import React, {
  forwardRef,
  useCallback,
  useImperativeHandle,
  useMemo,
  useRef,
} from 'react';
import { StyleSheet } from 'react-native';
import Animated, {
  interpolate,
  useAnimatedScrollHandler,
  useAnimatedStyle,
  useSharedValue,
} from 'react-native-reanimated';
import type { ComponentType } from 'react';
import type { ListRenderItemInfo } from 'react-native';
import type { SharedValue } from 'react-native-reanimated';

const CARD_HEIGHT = 343;

interface CardProps {
  index: number;
  scrollY: SharedValue<number>;
  children: React.ReactNode;
}

const Card: ComponentType<CardProps> = ({ index, scrollY, children }) => {
  const animatedStyle = useAnimatedStyle(() => {
    const scale = interpolate(
      scrollY.value,
      [
        (index - 1) * CARD_HEIGHT,
        (index - 0.5) * CARD_HEIGHT,
        index * CARD_HEIGHT,
        (index + 1) * CARD_HEIGHT,
        (index + 2) * CARD_HEIGHT,
      ],
      [0.9, 0.95, 1, 0.95, 0.9],
    );

    const opacity = interpolate(scale, [0.9, 1], [0.6, 1]);

    return {
      transform: [{ scale }],
      opacity,
    };
  });

  return (
    <Animated.View style={[cardStyles.card, animatedStyle]}>
      {children}
    </Animated.View>
  );
};

const cardStyles = StyleSheet.create({
  card: {
    borderRadius: 8,
    height: CARD_HEIGHT,
  },
});

export interface VerticalCarouselHandle {
  scrollToTop: () => void;
}

type VerticalCarouselProps<T> = {
  offsetTop?: number;
  data: T[];
  onScroll?: (sharedValue: SharedValue<number>) => void;
  renderItem: (props: ListRenderItemInfo<T>) => React.ReactElement;
};

export const VerticalCarousel = forwardRef(function VerticalCarousel<
  T extends object,
>(
  { offsetTop = 0, data, renderItem, onScroll }: VerticalCarouselProps<T>,
  ref: React.ForwardedRef<VerticalCarouselHandle>,
) {
  const scrollY = useSharedValue(0);
  const flatListRef = useRef<Animated.FlatList<T>>(null);

  useImperativeHandle(ref, () => ({
    scrollToTop: () => {
      flatListRef.current?.scrollToOffset({ offset: 0, animated: true });
    },
  }));

  const scrollHandler = useAnimatedScrollHandler(event => {
    scrollY.value = event.contentOffset.y;
    onScroll?.(scrollY);
  });

  const renderCard = useCallback(
    (props: ListRenderItemInfo<T>) => (
      <Card index={props.index} scrollY={scrollY}>
        {renderItem(props)}
      </Card>
    ),
    [renderItem],
  );

  const contentContainerStyle = useMemo(() => {
    return {
      paddingTop: offsetTop,
      paddingBottom: 24,
    };
  }, []);

  return (
    <Animated.FlatList
      ref={flatListRef}
      style={styles.list}
      data={data}
      renderItem={renderCard}
      keyExtractor={(_, index) => index.toString()}
      onScroll={scrollHandler}
      scrollEventThrottle={16}
      showsVerticalScrollIndicator={false}
      snapToInterval={CARD_HEIGHT}
      decelerationRate="fast"
      contentContainerStyle={contentContainerStyle}
    />
  );
}) as <T extends object>(
  props: VerticalCarouselProps<T> & {
    ref?: React.ForwardedRef<VerticalCarouselHandle>;
  },
) => React.ReactElement;

const styles = StyleSheet.create({
  list: {
    flex: 1,
    minHeight: 0,
  },
});
