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
  const bodyColor = selected ? '#fff1a8' : '#f7f1df';

  return (
    <group>
      {selected && (
        <mesh position={[0, -0.49, 0]} rotation={[-Math.PI / 2, 0, 0]} receiveShadow>
          <ringGeometry args={[0.44, 0.64, 40]} />
          <meshStandardMaterial
            color="#ffd24a"
            emissive="#b88a12"
            emissiveIntensity={0.28}
            transparent
            opacity={0.95}
          />
        </mesh>
      )}
      <RoundedBox args={[0.86, 0.86, 0.86]} radius={0.09} smoothness={5} castShadow receiveShadow>
        <meshPhysicalMaterial
          color={bodyColor}
          roughness={0.36}
          metalness={0.05}
          clearcoat={0.44}
          clearcoatRoughness={0.26}
          emissive={selected ? '#d49d00' : '#000000'}
          emissiveIntensity={selected ? 0.18 : 0}
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
