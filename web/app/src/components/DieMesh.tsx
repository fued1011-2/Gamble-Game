import { RoundedBox } from '@react-three/drei';
import { FACE_CONFIG, FACE_OFFSETS } from '../constants/dice';
import type { FaceValue } from '../types/dice';

function PipFace({ value }: { value: FaceValue }) {
  return (
    <group>
      {FACE_OFFSETS[value].map(([x, y], index) => (
        <mesh key={`${value}-${index}`} position={[x, y, 0]}>
          <circleGeometry args={[0.075, 20]} />
          <meshStandardMaterial color="#141414" roughness={0.35} metalness={0.1} />
        </mesh>
      ))}
    </group>
  );
}

export function DieMesh({ selected }: { selected: boolean }) {
  const bodyColor = selected ? '#fff4ba' : '#f7f1df';

  return (
    <group>
      <RoundedBox args={[0.86, 0.86, 0.86]} radius={0.09} smoothness={5} castShadow receiveShadow>
        <meshPhysicalMaterial
          color={bodyColor}
          roughness={0.42}
          metalness={0.04}
          clearcoat={0.35}
          clearcoatRoughness={0.35}
          emissive={selected ? '#d3a400' : '#000000'}
          emissiveIntensity={selected ? 0.14 : 0}
        />
      </RoundedBox>
      {FACE_CONFIG.map((face) => (
        <group
          key={face.value}
          position={[face.position[0] * 0.72, face.position[1] * 0.72, face.position[2] * 0.72]}
          rotation={face.rotation}
        >
          <PipFace value={face.value} />
        </group>
      ))}
    </group>
  );
}

