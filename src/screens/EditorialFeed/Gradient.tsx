import { ComponentType } from 'react';
import Svg, { Defs, LinearGradient, Rect, Stop } from 'react-native-svg';

type Props = {
  height: number;
};

export const Gradient: ComponentType<Props> = ({ height }) => {
  return (
    <Svg height={height} width="100%">
      <Defs>
        <LinearGradient id="headerGradient" x1="0%" y1="0%" x2="0%" y2="100%">
          <Stop
            offset="0%"
            stopColor="#fff"
            stopOpacity="1"
          />
          <Stop
            offset="90%"
            stopColor="#fff"
            stopOpacity="0"
          />
        </LinearGradient>
      </Defs>
      <Rect
        x="0"
        y="0"
        width="100%"
        height={height}
        fill="url(#headerGradient)"
      />
    </Svg>
  );
};
