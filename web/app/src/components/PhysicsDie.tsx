import { CuboidCollider, RigidBody, RapierRigidBody } from '@react-three/rapier';
import { useEffect, useRef, useState } from 'react';
import * as THREE from 'three';
import { DieMesh } from './DieMesh';
import { getTopFaceFromQuaternion } from '../lib/diceMath';
import type { DieSeed, FaceValue, RollPhase } from '../types/dice';

export function PhysicsDie({
  die,
  onToggle,
  onValueChange,
  onSettled,
  isRolling,
  rollPhase,
}: {
  die: DieSeed;
  onToggle: (id: number) => void;
  onValueChange: (id: number, value: FaceValue) => void;
  onSettled: (id: number) => void;
  isRolling: boolean;
  rollPhase: RollPhase;
}) {
  const bodyRef = useRef<RapierRigidBody | null>(null);
  const lastPlacementKeyRef = useRef<string | undefined>(undefined);
  const [hovered, setHovered] = useState(false);

  useEffect(() => {
    const body = bodyRef.current;
    if (!body) return;
    if (!die.placementKey || lastPlacementKeyRef.current === die.placementKey) return;

    lastPlacementKeyRef.current = die.placementKey;

    body.setTranslation({ x: die.position[0], y: die.position[1], z: die.position[2] }, true);
    body.setLinvel({ x: 0, y: 0, z: 0 }, true);
    body.setAngvel({ x: 0, y: 0, z: 0 }, true);

    if (!die.selected && rollPhase === 'pouring') {
      body.applyImpulse(
        {
          x: (die.id - 3.5) * 0.08,
          y: 0.32 + die.id * 0.02,
          z: -2.1 - die.id * 0.08,
        },
        true
      );
      body.applyTorqueImpulse(
        {
          x: 0.45 + die.id * 0.08,
          y: 0.32 + die.id * 0.05,
          z: 0.36 + die.id * 0.06,
        },
        true
      );
    }
  }, [die.position, die.id, die.selected, die.placementKey, rollPhase]);

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
        if (!die.selected && rollPhase === 'pouring') {
          onSettled(die.id);
        }
        return;
      }

      raf = requestAnimationFrame(poll);
    };

    raf = requestAnimationFrame(poll);
    return () => cancelAnimationFrame(raf);
  }, [die.id, die.position, onValueChange, onSettled, isRolling, die.selected, rollPhase]);

  useEffect(() => {
    if (!hovered) return;
    document.body.style.cursor = isRolling ? 'default' : 'pointer';
    return () => {
      document.body.style.cursor = 'default';
    };
  }, [hovered, isRolling]);

  return (
    <RigidBody
      ref={bodyRef}
      colliders={false}
      restitution={0.1}
      friction={1.15}
      angularDamping={1.28}
      linearDamping={1.02}
      canSleep={true}
      enabledRotations={[true, true, true]}
    >
      <CuboidCollider args={[0.36, 0.36, 0.36]} restitution={0.28} friction={0.95} />
      <group
        onClick={() => !isRolling && onToggle(die.id)}
        onPointerOver={(event) => {
          event.stopPropagation();
          setHovered(true);
        }}
        onPointerOut={(event) => {
          event.stopPropagation();
          setHovered(false);
        }}
      >
        <DieMesh selected={die.selected} hovered={hovered} interactive={!isRolling} />
      </group>
    </RigidBody>
  );
}
