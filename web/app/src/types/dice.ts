export type FaceValue = 1 | 2 | 3 | 4 | 5 | 6;

export type DieSeed = {
  id: number;
  position: [number, number, number];
  selected: boolean;
};

export type RollPhase = 'idle' | 'loading' | 'pouring';
