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

export function DieMesh({
  selected,
  hovered,
  interactive,
}: {
  selected: boolean;
  hovered: boolean;
  interactive: boolean;
}) {
  const bodyColor = selected ? '#fff1a8' : hovered ? '#fff7e8' : '#f7f1df';
  const ringOpacity = selected ? 0.95 : hovered ? 0.38 : 0;
  const ringColor = selected ? '#ffd24a' : '#f1e0a2';
  const baseScale = hovered && interactive ? 0.9 : 0.865;

  return (
    <group scale={baseScale}>
      {(selected || hovered) && (
        <mesh position={[0, -0.46, 0]} rotation={[-Math.PI / 2, 0, 0]} receiveShadow>
          <ringGeometry args={[0.4, 0.58, 40]} />
          <meshStandardMaterial
            color={ringColor}
            emissive={selected ? '#b88a12' : '#6f6130'}
            emissiveIntensity={selected ? 0.28 : 0.12}
            transparent
            opacity={ringOpacity}
          />
        </mesh>
      )}
      <RoundedBox args={[0.86, 0.86, 0.86]} radius={0.09} smoothness={5} castShadow receiveShadow>
        <meshPhysicalMaterial
          color={bodyColor}
          roughness={hovered && interactive ? 0.3 : 0.36}
          metalness={0.05}
          clearcoat={hovered && interactive ? 0.5 : 0.44}
          clearcoatRoughness={0.26}
          emissive={selected ? '#d49d00' : hovered ? '#5a4a19' : '#000000'}
          emissiveIntensity={selected ? 0.18 : hovered ? 0.05 : 0}
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
