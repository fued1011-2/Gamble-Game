import { CuboidCollider, CylinderCollider, RigidBody } from '@react-three/rapier';
import { CUP_POSITION } from '../constants/dice';

export function TrayColliders() {
  return (
    <RigidBody type="fixed" colliders={false}>
      <CuboidCollider args={[5.6, 0.11, 5.6]} position={[0, 0, 0]} restitution={0.15} friction={0.9} />
      <CuboidCollider args={[5.675, 0.675, 0.225]} position={[0, 0.72, -5.25]} restitution={0.2} friction={0.8} />
      <CuboidCollider args={[5.675, 0.675, 0.225]} position={[0, 0.72, 5.25]} restitution={0.2} friction={0.8} />
      <CuboidCollider args={[0.225, 0.675, 5.45]} position={[-5.25, 0.72, 0]} restitution={0.2} friction={0.8} />
      <CuboidCollider args={[0.225, 0.675, 5.45]} position={[5.25, 0.72, 0]} restitution={0.2} friction={0.8} />
    </RigidBody>
  );
}

/**
 * Der Becher braucht echte Collider, sonst fällt alles einfach durch und die Inszenierung ist Betrug.
 */
export function CupColliders() {
  return (
    <RigidBody type="fixed" colliders={false} position={CUP_POSITION} rotation={[-0.22, 0, 0]}>
      <CuboidCollider args={[1.45, 0.1, 1.45]} position={[0, -1.65, 0]} friction={0.98} restitution={0.08} />
      <CuboidCollider args={[0.1, 1.45, 1.35]} position={[1.42, -0.02, 0]} friction={0.92} restitution={0.08} />
      <CuboidCollider args={[0.1, 1.45, 1.35]} position={[-1.42, -0.02, 0]} friction={0.92} restitution={0.08} />
      <CuboidCollider args={[1.35, 1.45, 0.1]} position={[0, -0.02, 1.42]} friction={0.92} restitution={0.08} />
      <CuboidCollider args={[1.35, 1.45, 0.1]} position={[0, -0.02, -1.42]} friction={0.92} restitution={0.08} />
    </RigidBody>
  );
}

export function TrayVisual() {
  return (
    <group>
      <mesh receiveShadow position={[0, 0, 0]}>
        <boxGeometry args={[11.2, 0.22, 11.2]} />
        <meshStandardMaterial color="#7a1f1f" roughness={0.96} metalness={0.03} />
      </mesh>
      <mesh receiveShadow position={[0, 0.18, 0]}>
        <boxGeometry args={[10.6, 0.08, 10.6]} />
        <meshStandardMaterial color="#922828" roughness={0.92} metalness={0.02} />
      </mesh>
      <mesh receiveShadow position={[0, 0.72, -5.25]}>
        <boxGeometry args={[11.35, 1.35, 0.45]} />
        <meshStandardMaterial color="#241a16" roughness={0.82} metalness={0.08} />
      </mesh>
      <mesh receiveShadow position={[0, 0.72, 5.25]}>
        <boxGeometry args={[11.35, 1.35, 0.45]} />
        <meshStandardMaterial color="#241a16" roughness={0.82} metalness={0.08} />
      </mesh>
      <mesh receiveShadow position={[-5.25, 0.72, 0]}>
        <boxGeometry args={[0.45, 1.35, 10.9]} />
        <meshStandardMaterial color="#241a16" roughness={0.82} metalness={0.08} />
      </mesh>
      <mesh receiveShadow position={[5.25, 0.72, 0]}>
        <boxGeometry args={[0.45, 1.35, 10.9]} />
        <meshStandardMaterial color="#241a16" roughness={0.82} metalness={0.08} />
      </mesh>
      <mesh receiveShadow position={[0, 0.46, -4.45]}>
        <boxGeometry args={[9.5, 0.05, 1.25]} />
        <meshStandardMaterial color="#304f2e" roughness={0.88} metalness={0.02} />
      </mesh>
    </group>
  );
}
