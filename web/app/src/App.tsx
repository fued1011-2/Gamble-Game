import { Canvas } from '@react-three/fiber';
import { ContactShadows, OrbitControls, RoundedBox } from '@react-three/drei';
import { CuboidCollider, CylinderCollider, Physics, RigidBody, RapierRigidBody } from '@react-three/rapier';
import { useEffect, useMemo, useRef, useState } from 'react';
import * as THREE from 'three';

type FaceValue = 1 | 2 | 3 | 4 | 5 | 6;

type DieSeed = {
  id: number;
  position: [number, number, number];
  selected: boolean;
};

const CUP_POSITION: [number, number, number] = [0, 4.6, 6.4];
const CUP_INTERIOR_POINTS: Array<[number, number, number]> = [
  [-0.42, 0.5, -0.18],
  [0.42, 0.64, -0.08],
  [-0.18, 1.02, 0.16],
  [0.18, 1.18, -0.24],
  [-0.36, 1.48, 0.18],
  [0.36, 1.62, 0.05],
];

const INITIAL_DICE: DieSeed[] = [
  { id: 1, position: [-3.75, 2.2, 0.35], selected: false },
  { id: 2, position: [-2.25, 2.3, -0.25], selected: false },
  { id: 3, position: [-0.75, 2.1, 0.1], selected: false },
  { id: 4, position: [0.75, 2.35, -0.18], selected: false },
  { id: 5, position: [2.25, 2.15, 0.24], selected: false },
  { id: 6, position: [3.75, 2.28, -0.08], selected: false },
];

const FACE_OFFSETS: Record<FaceValue, [number, number][]> = {
  1: [[0, 0]],
  2: [[-0.22, -0.22], [0.22, 0.22]],
  3: [[-0.24, -0.24], [0, 0], [0.24, 0.24]],
  4: [[-0.22, -0.22], [0.22, -0.22], [-0.22, 0.22], [0.22, 0.22]],
  5: [[-0.22, -0.22], [0.22, -0.22], [0, 0], [-0.22, 0.22], [0.22, 0.22]],
  6: [[-0.22, -0.25], [0.22, -0.25], [-0.22, 0], [0.22, 0], [-0.22, 0.25], [0.22, 0.25]],
};

const FACE_CONFIG: Array<{
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

function getTopFaceFromQuaternion(quaternion: THREE.Quaternion): FaceValue {
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

function DieMesh({ selected }: { selected: boolean }) {
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
        <group key={face.value} position={[face.position[0] * 0.86, face.position[1] * 0.86, face.position[2] * 0.86]} rotation={face.rotation}>
          <PipFace value={face.value} />
        </group>
      ))}
    </group>
  );
}

function DiceCup({ isRolling }: { isRolling: boolean }) {
  const groupRef = useRef<THREE.Group>(null);

  useEffect(() => {
    const group = groupRef.current;
    if (!group) return;
    let frame = 0;
    let raf = 0;

    const animate = () => {
      frame += 1;
      if (isRolling) {
        const t = frame / 60;
        group.position.set(CUP_POSITION[0], CUP_POSITION[1] + Math.sin(t * 14) * 0.12, CUP_POSITION[2]);
        group.rotation.set(-0.22 + Math.sin(t * 10) * 0.06, 0, Math.sin(t * 12) * 0.1);
      } else {
        group.position.set(...CUP_POSITION);
        group.rotation.set(-0.22, 0, 0);
      }
      raf = requestAnimationFrame(animate);
    };

    raf = requestAnimationFrame(animate);
    return () => cancelAnimationFrame(raf);
  }, [isRolling]);

  return (
    <group ref={groupRef} position={CUP_POSITION} rotation={[-0.22, 0, 0]}>
      <mesh castShadow receiveShadow>
        <cylinderGeometry args={[1.35, 1.6, 3.1, 32, 1, true]} />
        <meshStandardMaterial color="#26211b" roughness={0.72} metalness={0.1} side={THREE.DoubleSide} />
      </mesh>
      <mesh position={[0, -1.55, 0]} castShadow receiveShadow>
        <cylinderGeometry args={[1.58, 1.58, 0.2, 32]} />
        <meshStandardMaterial color="#1b1713" roughness={0.85} metalness={0.06} />
      </mesh>
      <mesh position={[0, 1.55, 0]} castShadow>
        <torusGeometry args={[1.42, 0.08, 12, 32]} />
        <meshStandardMaterial color="#56473a" roughness={0.5} metalness={0.12} />
      </mesh>
    </group>
  );
}

function TrayColliders() {
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

function CupColliders() {
  return (
    <RigidBody type="fixed" colliders={false} position={CUP_POSITION} rotation={[-0.22, 0, 0]}>
      <CylinderCollider args={[1.45, 1.28]} position={[0, 0, 0]} />
      <CuboidCollider args={[1.3, 0.08, 1.3]} position={[0, -1.45, 0]} friction={0.95} restitution={0.15} />
      <CuboidCollider args={[0.08, 1.3, 1.2]} position={[1.24, 0, 0]} friction={0.9} restitution={0.12} />
      <CuboidCollider args={[0.08, 1.3, 1.2]} position={[-1.24, 0, 0]} friction={0.9} restitution={0.12} />
      <CuboidCollider args={[1.2, 1.3, 0.08]} position={[0, 0, 1.24]} friction={0.9} restitution={0.12} />
      <CuboidCollider args={[1.2, 1.3, 0.08]} position={[0, 0, -1.24]} friction={0.9} restitution={0.12} />
    </RigidBody>
  );
}

function TrayVisual() {
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

function PhysicsDie({ die, onToggle, onValueChange, isRolling }: {
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
          x: (die.id - 3.5) * 0.33,
          y: 1.4 + die.id * 0.06,
          z: -4.2 - die.id * 0.15,
        },
        true
      );
      body.applyTorqueImpulse(
        {
          x: 2 + die.id * 0.35,
          y: 1.3 + die.id * 0.26,
          z: 1.6 + die.id * 0.24,
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
      const motion = Math.abs(ang.x) + Math.abs(ang.y) + Math.abs(ang.z) + Math.abs(lin.x) + Math.abs(lin.y) + Math.abs(lin.z);

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
      angularDamping={0.68}
      linearDamping={0.5}
      canSleep={true}
      enabledRotations={[true, true, true]}
    >
      <group onClick={() => !isRolling && onToggle(die.id)}>
        <DieMesh selected={die.selected} />
      </group>
    </RigidBody>
  );
}

export default function App() {
  const [dice, setDice] = useState(INITIAL_DICE);
  const [rollCount, setRollCount] = useState(0);
  const [isRolling, setIsRolling] = useState(false);
  const [detectedValues, setDetectedValues] = useState<Record<number, FaceValue>>({ 1: 1, 2: 1, 3: 1, 4: 1, 5: 1, 6: 1 });

  const updateDetectedValue = (id: number, value: FaceValue) => {
    setDetectedValues((current) => (current[id] === value ? current : { ...current, [id]: value }));
  };

  const toggleDie = (id: number) => {
    if (isRolling) return;
    setDice((current) => {
      const toggled = current.map((die) => (die.id === id ? { ...die, selected: !die.selected } : die));
      const selected = toggled.filter((die) => die.selected).sort((a, b) => a.id - b.id);
      const unselected = toggled.filter((die) => !die.selected).sort((a, b) => a.id - b.id);

      const reflowedSelected = selected.map((die, index) => ({
        ...die,
        position: [-3.6 + index * 1.2, 1.0, -4.45] as [number, number, number],
      }));

      const reflowedUnselected = unselected.map((die, index) => {
        const p = CUP_INTERIOR_POINTS[index % CUP_INTERIOR_POINTS.length];
        return {
          ...die,
          position: [CUP_POSITION[0] + p[0], CUP_POSITION[1] - 1.2 + p[1], CUP_POSITION[2] + p[2]] as [number, number, number],
        };
      });

      return [...reflowedSelected, ...reflowedUnselected].sort((a, b) => a.id - b.id);
    });
  };

  const rollDice = () => {
    if (isRolling) return;
    setIsRolling(true);
    setRollCount((count) => count + 1);

    setDice((current) =>
      current.map((die, index) => {
        if (die.selected) return die;
        const p = CUP_INTERIOR_POINTS[index % CUP_INTERIOR_POINTS.length];
        return {
          ...die,
          position: [CUP_POSITION[0] + p[0], CUP_POSITION[1] - 1.2 + p[1], CUP_POSITION[2] + p[2]] as [number, number, number],
        };
      })
    );

    setTimeout(() => setIsRolling(false), 1900);
  };

  const reset = () => {
    setDice(INITIAL_DICE);
    setRollCount(0);
    setIsRolling(false);
    setDetectedValues({ 1: 1, 2: 1, 3: 1, 4: 1, 5: 1, 6: 1 });
  };

  const selectedDice = useMemo(() => dice.filter((die) => die.selected).map((die) => ({ ...die, topValue: detectedValues[die.id] })), [dice, detectedValues]);
  const activeDice = useMemo(() => dice.filter((die) => !die.selected).map((die) => ({ ...die, topValue: detectedValues[die.id] })), [dice, detectedValues]);

  return (
    <div className="app-shell">
      <div className="hud top">
        <div>
          <h1>Gamble Game Web Spike</h1>
          <p>Arbeitsblock 1D: Becher-basierter Wurf mit echter Physik und besserem Halteraum.</p>
        </div>
        <div className="hud-box">
          <strong>Selected Dice:</strong> {selectedDice.length} / 6
          <br />
          <strong>Banked Top Values:</strong> {selectedDice.map((die) => die.topValue).join(', ') || 'none'}
        </div>
      </div>

      <div className="controls">
        <button onClick={rollDice} disabled={isRolling}>{isRolling ? 'Rolling…' : 'Roll From Cup'}</button>
        <button onClick={reset} disabled={isRolling}>Reset</button>
      </div>

      <div className="hint-panel">
        <strong>Spike-Fokus:</strong> aktive Würfel im Becher halten, aus dem Becher in den Tray schütten und die obere Seite aus der echten Endlage erkennen.
      </div>

      <div className="value-panel">
        <div><strong>Active Top Values:</strong> {activeDice.map((die) => die.topValue).join(', ') || 'none'}</div>
        <div><strong>Detected Total:</strong> {activeDice.reduce((sum, die) => sum + die.topValue, 0)}</div>
      </div>

      <Canvas shadows camera={{ position: [0, 8.4, 9.6], fov: 38 }}>
        <color attach="background" args={['#21382c']} />
        <fog attach="fog" args={['#21382c', 10, 24]} />
        <ambientLight intensity={1.18} />
        <directionalLight position={[6, 12, 5]} intensity={2.5} castShadow shadow-mapSize-width={2048} shadow-mapSize-height={2048} />
        <pointLight position={[-4.5, 7, -2.5]} intensity={13} color="#ffd9a0" />
        <pointLight position={[4.5, 5.5, 3.5]} intensity={7} color="#b8d7ff" />

        <DiceCup isRolling={isRolling} />
        <Physics gravity={[0, -12, 0]}>
          <TrayColliders />
          <CupColliders />
          {dice.map((die) => (
            <PhysicsDie key={`${die.id}-${rollCount}`} die={die} onToggle={toggleDie} onValueChange={updateDetectedValue} isRolling={isRolling} />
          ))}
        </Physics>
        <TrayVisual />
        <ContactShadows position={[0, 0.12, 0]} opacity={0.5} scale={20} blur={2.4} far={10} />
        <OrbitControls enablePan={false} minPolarAngle={0.75} maxPolarAngle={1.25} minDistance={8.5} maxDistance={14} />
      </Canvas>
    </div>
  );
}
