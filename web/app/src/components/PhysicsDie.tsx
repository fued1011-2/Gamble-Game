import { RigidBody, RapierRigidBody } from '@react-three/rapier';
import { useEffect, useRef } from 'react';
import * as THREE from 'three';
import { DieMesh } from './DieMesh';
import { getTopFaceFromQuaternion } from '../lib/diceMath';
import type { DieSeed, FaceValue } from '../types/dice';

export function PhysicsDie({
  die,
  onToggle,
  onValueChange,
  isRolling,
}: {
  die: DieSeed;
  onToggle: (id: number) => void;
  onValueChange: (id: number, value: FaceValue) => void;
  isRolling: boolean;
}) {
  const bodyRef = useRef<RapierRigidBody | null>(null);

  useEffect(() => {
    const body = bodyRef.current;
    if (!body) return;

    body.setTranslation({ x: die.position[0], y: die.position[1], z: die.position[2] }, true);
    body.setLinvel({ x: 0, y: 0, z: 0 }, true);
    body.setAngvel({ x: 0, y: 0, z: 0 }, true);

    if (!die.selected) {
      body.applyImpulse(
        {
          x: (die.id - 3.5) * 0.24,
          y: 1.1 + die.id * 0.05,
          z: -3.2 - die.id * 0.12,
        },
        true
      );
      body.applyTorqueImpulse(
        {
          x: 1.45 + die.id * 0.28,
          y: 1.05 + die.id * 0.18,
          z: 1.1 + die.id * 0.18,
        },
        true
      );
    }
  }, [die.position[0], die.position[1], die.position[2], die.id, die.selected]);

  useEffect(() => {
    let frame = 0;
    let stoppedFrames = 0;
    let raf = 0;

    const poll = () => {
      const body = bodyRef.current;
      if (!body) return;
      frame += 1;

      const ang = body.angvel();
      const lin = body.linvel();
      const motion =
        Math.abs(ang.x) +
        Math.abs(ang.y) +
        Math.abs(ang.z) +
        Math.abs(lin.x) +
        Math.abs(lin.y) +
        Math.abs(lin.z);

      if (motion < 0.08) stoppedFrames += 1;
      else stoppedFrames = 0;

      if (frame > 20 && stoppedFrames > 8) {
        const rot = body.rotation();
        const quat = new THREE.Quaternion(rot.x, rot.y, rot.z, rot.w);
        onValueChange(die.id, getTopFaceFromQuaternion(quat));
        return;
      }

      raf = requestAnimationFrame(poll);
    };

    raf = requestAnimationFrame(poll);
    return () => cancelAnimationFrame(raf);
  }, [die.id, die.position, onValueChange, isRolling]);

  return (
    <RigidBody
      ref={bodyRef}
      colliders="cuboid"
      restitution={0.28}
      friction={0.95}
      angularDamping={0.86}
      linearDamping={0.62}
      canSleep={true}
      enabledRotations={[true, true, true]}
    >
      <group onClick={() => !isRolling && onToggle(die.id)}>
        <DieMesh selected={die.selected} />
      </group>
    </RigidBody>
  );
}
