import * as THREE from 'three';
import type { DieSeed, FaceValue } from '../types/dice';

export const CUP_POSITION: [number, number, number] = [0, 4.6, 6.4];

export const CUP_INTERIOR_POINTS: Array<[number, number, number]> = [
  [-0.42, 0.5, -0.18],
  [0.42, 0.64, -0.08],
  [-0.18, 1.02, 0.16],
  [0.18, 1.18, -0.24],
  [-0.36, 1.48, 0.18],
  [0.36, 1.62, 0.05],
];

export const INITIAL_DICE: DieSeed[] = [
  { id: 1, position: [-3.75, 2.2, 0.35], selected: false },
  { id: 2, position: [-2.25, 2.3, -0.25], selected: false },
  { id: 3, position: [-0.75, 2.1, 0.1], selected: false },
  { id: 4, position: [0.75, 2.35, -0.18], selected: false },
  { id: 5, position: [2.25, 2.15, 0.24], selected: false },
  { id: 6, position: [3.75, 2.28, -0.08], selected: false },
];

export const FACE_OFFSETS: Record<FaceValue, [number, number][]> = {
  1: [[0, 0]],
  2: [[-0.22, -0.22], [0.22, 0.22]],
  3: [[-0.24, -0.24], [0, 0], [0.24, 0.24]],
  4: [[-0.22, -0.22], [0.22, -0.22], [-0.22, 0.22], [0.22, 0.22]],
  5: [[-0.22, -0.22], [0.22, -0.22], [0, 0], [-0.22, 0.22], [0.22, 0.22]],
  6: [[-0.22, -0.25], [0.22, -0.25], [-0.22, 0], [0.22, 0], [-0.22, 0.25], [0.22, 0.25]],
};

export const FACE_CONFIG: Array<{
  value: FaceValue;
  position: [number, number, number];
  rotation: [number, number, number];
  localNormal: THREE.Vector3;
}> = [
  { value: 1, position: [0, 0, 0.505], rotation: [0, 0, 0], localNormal: new THREE.Vector3(0, 0, 1) },
  { value: 6, position: [0, 0, -0.505], rotation: [0, Math.PI, 0], localNormal: new THREE.Vector3(0, 0, -1) },
  { value: 2, position: [0.505, 0, 0], rotation: [0, Math.PI / 2, 0], localNormal: new THREE.Vector3(1, 0, 0) },
  { value: 5, position: [-0.505, 0, 0], rotation: [0, -Math.PI / 2, 0], localNormal: new THREE.Vector3(-1, 0, 0) },
  { value: 3, position: [0, 0.505, 0], rotation: [-Math.PI / 2, 0, 0], localNormal: new THREE.Vector3(0, 1, 0) },
  { value: 4, position: [0, -0.505, 0], rotation: [Math.PI / 2, 0, 0], localNormal: new THREE.Vector3(0, -1, 0) },
];
