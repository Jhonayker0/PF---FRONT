import { Text } from 'react-native';
import React, { useMemo } from 'react';
import { Image, Pressable, View, StyleSheet } from 'react-native';
import type { ComponentType } from 'react';
import type { EditorialArticleItem } from './data/articles';
import { usersData } from './data/users';
import { formatRelativeDate } from './utils/date';

type IconWithTextProps = {
  text: string;
  icon: 'Eye' | 'Share';
};

const IconWithText: ComponentType<IconWithTextProps> = ({ text, icon }) => {
  const iconSymbol = icon === 'Eye' ? '👁️' : '📤';
  return (
    <View style={iconWithTextStyles.container}>
      <Text style={{ fontSize: 14 }}>{iconSymbol}</Text>
      <Text style={{ fontSize: 12, color: '#333' }}>{text}</Text>
    </View>
  );
};

const iconWithTextStyles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    gap: 8,
    alignItems: 'center',
  },
});

type Props = {
  item: EditorialArticleItem;
  onPress: (id: EditorialArticleItem['id']) => void;
};

export const Card: ComponentType<Props> = ({ item, onPress }) => {
  const author = useMemo(
    () =>
      (item?.authorId
        ? usersData.find(user => user.id === item?.authorId)
        : undefined) ?? { name: 'Unknown' },
    [item?.authorId],
  );

  return (
    <Pressable onPress={() => onPress(item.id)} style={styles.container}>
      <View key={item.id} style={styles.card}>
        <View style={styles.cardImageContainer}>
          {/* Using a library like react-native-fast-image can prevent the image from being refetched */}
          <Image source={{ uri: item.imageURL }} style={styles.cardImage} />
          <View style={styles.cardTitleContainer}>
            <Text style={styles.cardTitle}>{item.title}</Text>
            <Text style={styles.cardSubtitle}>
              {author.name} • {formatRelativeDate(item.createdAt)}
            </Text>
          </View>
          <Text
            style={styles.cardDescriptionText}
            numberOfLines={5}
          >
            {item.description}
          </Text>
        </View>
        <View style={styles.cardFooter}>
          <IconWithText text={item.views.toLocaleString()} icon="Eye" />
          <IconWithText text={item.shares.toLocaleString()} icon="Share" />
        </View>
      </View>
    </Pressable>
  );
};

const styles = StyleSheet.create({
  container: {
  },
  card: {
    height: 350,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: '#e0e0e0',
    overflow: 'hidden',
    backgroundColor: '#fff',
    padding: 4,
  },
  cardImageContainer: {
    gap: 8,
  },
  cardImage: {
    height: 200,
    width: '100%',
    borderRadius: 10,
  },
  cardTitleContainer: {
    paddingHorizontal: 8,
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#1a1a1a',
  },
  cardSubtitle: {
    fontSize: 12,
    color: '#999',
  },
  cardDescriptionText: {
    paddingTop: 2,
    paddingHorizontal: 8,
    fontSize: 14,
    color: '#666',
  },
  cardFooter: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    paddingHorizontal: 12,
    paddingVertical: 8,
    gap: 16,
    flexDirection: 'row',
  },
});
