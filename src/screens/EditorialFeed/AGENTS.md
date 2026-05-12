# AGENTS.md

## Template Purpose

Vertical carousel content feed with category filtering and smooth animations. Use for news apps, content discovery, or article browsing experiences.

**IMPORTANT:** Always reference `info.json` for exact dependencies and component structure.

### Core Components Structure

```
EditorialFeed/
├── EditorialFeedScreen.tsx            # Main feed container
├── Header.tsx                         # Fixed header with categories
├── Categories.tsx                     # Category filter component
├── Card.tsx                          # Individual article card
├── VerticalCarousel.tsx              # Animated carousel container
├── Gradient.tsx                      # Visual overlay effects
├── ProfileBottomSheet.tsx            # User profile modal
├── data/                            # Mock articles, categories, users
└── utils/date.ts                    # Date formatting utilities
```

### Design System Usage

Built with **craftrn-ui** components and **Unistyles** theming:

- Reference the unified theme system at `@demo-app/craftrn-ui/themes/` for all styling decisions
- `Card` for article containers
- `Avatar` and `ButtonRound` for user interactions
- `BottomSheet` for profile and settings
- Category-based color theming

## Data Structure & API Integration

### Mock Data Model

```typescript
type EditorialArticleItem = {
  id: string;
  title: string;
  description: string;
  categories: string[];
  tags: string[];
  views: number;
  shares: number;
  createdAt: string;
  imageURL: string;
  authorId: string;
  readingTime: number;
  body: string;
};

type EditorialCategory = {
  title: string;
  color: string;
};
```

### API Integration with React Query

Recommended pattern for content feeds:

```typescript
// api/useFeedArticles.ts
export const useFeedArticles = (category?: string) => {
  return useInfiniteQuery({
    queryKey: ['feedArticles', category],
    queryFn: ({ pageParam = 1 }) =>
      fetch(`/api/articles?category=${category}&page=${pageParam}`).then(r =>
        r.json(),
      ),
    getNextPageParam: lastPage => lastPage.nextPage,
  });
};

// api/useCategories.ts
export const useCategories = () => {
  return useQuery({
    queryKey: ['categories'],
    queryFn: () => fetch('/api/categories').then(r => r.json()),
    staleTime: 1000 * 60 * 30, // 30 minutes cache
  });
};
```

## Template Customization Patterns

### Vertical Carousel Animation Pattern

Advanced scroll-based animations:

```typescript
const useCarouselAnimation = (cardHeight: number) => {
  const scrollY = useSharedValue(0);

  const createCardAnimation = (index: number) =>
    useAnimatedStyle(() => {
      const scale = interpolate(
        scrollY.value,
        [
          (index - 1) * cardHeight,
          index * cardHeight,
          (index + 1) * cardHeight,
        ],
        [0.9, 1, 0.9],
      );
      return {
        transform: [{ scale }],
        opacity: interpolate(scale, [0.9, 1], [0.6, 1]),
      };
    });

  // Follow existing animation patterns in VerticalCarousel.tsx
};
```

### Category Filtering Pattern

Dynamic content filtering with smooth transitions:

```typescript
const CategoryFilter = ({ categories, selectedCategory, onSelect }) => {
  // Use existing Categories.tsx component patterns
  // Implement smooth scroll reset on category change
  // Follow existing visual feedback patterns
};
```

## Template Extension & Reuse Patterns

### Content Feed Integration Options

Connect to various content sources:

```typescript
// CMS integration (Contentful, Strapi, Sanity)
// News APIs (NewsAPI, Guardian API)
// Custom content management systems
```

### Template Reuse Examples

This Editorial Feed template can be adapted for:

1. **News Feed**: Add breaking news indicators and real-time updates
2. **Social Media Feed**: Include user interactions and social features
3. **E-commerce Product Feed**: Add shopping features and product catalogs
4. **Video Content Feed**: Integrate video players and thumbnails
5. **Recipe Discovery**: Add cooking instructions and ingredient lists

### Adding New Features

- **Search Integration**: Add search functionality to filter articles
- **Bookmarking System**: Save articles for later reading
- **Recommendation Engine**: Personalized content suggestions
- **Social Sharing**: Native sharing integration with platforms
- **Offline Reading**: Cache articles for offline access

### Customization Guidelines

- Follow existing VerticalCarousel animation patterns
- Use craftrn-ui Card components for consistency
- Maintain category-based filtering system
- Preserve scroll performance optimizations
- Keep snap-to-interval behavior for cards
- Maintain feature-based file colocation - group related files together rather than separating by type (avoid generic `hooks/`, `components/` folders unless shared across multiple features)

## TypeScript Rules

**STRICT TYPING REQUIREMENTS:**

- NEVER use `any` type - always provide specific types
- NEVER use TypeScript type assertions (`as Type`, `<Type>value`) or casts
- Use proper type definitions and interfaces
- Use type guards and narrowing instead of assertions

## Dependencies & File Structure

Refer to `info.json` in this template directory for:

- `externalDependencies`: Required npm packages
- `craftrnUiComponents`: craftrn-ui components used
- `tetrislyIcons`: Icons from tetrisly icon set
- `fileStructure`: Complete component hierarchy and organization
