import { useEffect, useRef } from 'react';
import * as THREE from 'three';
import { CUP_POSITION } from '../constants/dice';
import type { RollPhase } from '../types/dice';

export function DiceCup({ rollPhase }: { rollPhase: RollPhase }) {
  const groupRef = useRef<THREE.Group>(null);

  useEffect(() => {
    const group = groupRef.current;
    if (!group) return;
    let frame = 0;
    let raf = 0;

    const animate = () => {
      frame += 1;
      if (rollPhase === 'loading') {
        const t = frame / 60;
        group.position.set(CUP_POSITION[0], CUP_POSITION[1] + Math.sin(t * 14) * 0.12, CUP_POSITION[2]);
        group.rotation.set(-0.22 + Math.sin(t * 10) * 0.06, 0, Math.sin(t * 12) * 0.1);
      } else if (rollPhase === 'pouring') {
        group.position.set(CUP_POSITION[0] + 0.15, CUP_POSITION[1] - 0.05, CUP_POSITION[2] - 0.35);
        group.rotation.set(-1.08, 0, 0.18);
      } else {
        group.position.set(...CUP_POSITION);
        group.rotation.set(-0.22, 0, 0);
      }
      raf = requestAnimationFrame(animate);
    };

    raf = requestAnimationFrame(animate);
    return () => cancelAnimationFrame(raf);
  }, [rollPhase]);

  return (
    <group ref={groupRef} position={CUP_POSITION} rotation={[-0.22, 0, 0]}>
      <mesh castShadow receiveShadow>
        <cylinderGeometry args={[1.6, 1.9, 3.5, 32, 1, true]} />
        <meshStandardMaterial color="#26211b" roughness={0.72} metalness={0.1} side={THREE.DoubleSide} />
      </mesh>
      <mesh position={[0, -1.75, 0]} castShadow receiveShadow>
        <cylinderGeometry args={[1.88, 1.88, 0.22, 32]} />
        <meshStandardMaterial color="#1b1713" roughness={0.85} metalness={0.06} />
      </mesh>
      <mesh position={[0, 1.75, 0]} castShadow>
        <torusGeometry args={[1.68, 0.09, 12, 32]} />
        <meshStandardMaterial color="#56473a" roughness={0.5} metalness={0.12} />
      </mesh>
    </group>
  );
}
