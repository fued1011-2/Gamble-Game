import * as THREE from 'three';
import { FACE_CONFIG } from '../constants/dice';
import type { FaceValue } from '../types/dice';

/**
 * Bestimmt die obere Würfelseite aus der echten Weltrotation des Würfels.
 * Genau diese Logik ist für das Spiel wichtig, weil die Augenzahl nicht frei erfunden,
 * sondern aus der Endlage abgeleitet werden soll.
 */
export function getTopFaceFromQuaternion(quaternion: THREE.Quaternion): FaceValue {
  const worldUp = new THREE.Vector3(0, 1, 0);
  let bestValue: FaceValue = 1;
  let bestDot = -Infinity;

  for (const face of FACE_CONFIG) {
    const normal = face.localNormal.clone().applyQuaternion(quaternion);
    const dot = normal.dot(worldUp);
    if (dot > bestDot) {
      bestDot = dot;
      bestValue = face.value;
    }
  }

  return bestValue;
}
