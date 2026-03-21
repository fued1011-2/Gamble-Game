import { Canvas } from '@react-three/fiber';
import { ContactShadows, OrbitControls, RoundedBox } from '@react-three/drei';
import { useEffect, useMemo, useRef, useState } from 'react';
import * as THREE from 'three';

type FaceValue = 1 | 2 | 3 | 4 | 5 | 6;

type DieState = {
  id: number;
  basePosition: [number, number, number];
  position: [number, number, number];
  rotation: [number, number, number];
  selected: boolean;
};

const INITIAL_DICE: DieState[] = [
  { id: 1, basePosition: [-3.75, 0.75, 0.35], position: [-3.75, 0.75, 0.35], rotation: [0.12, 0.3, -0.18], selected: false },
  { id: 2, basePosition: [-2.25, 0.72, -0.25], position: [-2.25, 0.72, -0.25], rotation: [-0.2, -0.45, 0.2], selected: false },
  { id: 3, basePosition: [-0.75, 0.74, 0.1], position: [-0.75, 0.74, 0.1], rotation: [0.35, 0.15, -0.28], selected: false },
  { id: 4, basePosition: [0.75, 0.76, -0.18], position: [0.75, 0.76, -0.18], rotation: [-0.1, 0.4, 0.25], selected: false },
  { id: 5, basePosition: [2.25, 0.73, 0.24], position: [2.25, 0.73, 0.24], rotation: [0.22, -0.2, 0.42], selected: false },
  { id: 6, basePosition: [3.75, 0.71, -0.08], position: [3.75, 0.71, -0.08], rotation: [-0.32, 0.22, -0.2], selected: false },
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

function getTopFace(rotation: [number, number, number]): FaceValue {
  const euler = new THREE.Euler(rotation[0], rotation[1], rotation[2]);
  const quaternion = new THREE.Quaternion().setFromEuler(euler);
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

function getFinalRotation(seed: number, index: number): [number, number, number] {
  const step = seed + index + 1;
  return [
    (step * 1.17) % (Math.PI * 2),
    (step * 0.91) % (Math.PI * 2),
    (step * 1.41) % (Math.PI * 2),
  ];
}

function lerp(a: number, b: number, t: number) {
  return a + (b - a) * t;
}

function easeOutCubic(t: number) {
  return 1 - Math.pow(1 - t, 3);
}

function Die({ die, onToggle, isRolling }: { die: DieState; onToggle: (id: number) => void; isRolling: boolean }) {
  const bodyColor = die.selected ? '#fff4ba' : '#f7f1df';
  const groupRef = useRef<THREE.Group>(null);
  const animationRef = useRef<number | null>(null);
  const prevPosition = useRef<THREE.Vector3>(new THREE.Vector3(...die.position));
  const prevRotation = useRef<THREE.Euler>(new THREE.Euler(...die.rotation));

  useEffect(() => {
    const group = groupRef.current;
    if (!group) return;

    if (animationRef.current) cancelAnimationFrame(animationRef.current);

    const startPos = prevPosition.current.clone();
    const endPos = new THREE.Vector3(...die.position);
    const startRot = prevRotation.current.clone();
    const endRot = new THREE.Euler(...die.rotation);
    const duration = isRolling && !die.selected ? 720 : 260;
    const startTime = performance.now();

    const animate = (time: number) => {
      const rawT = Math.min((time - startTime) / duration, 1);
      const t = easeOutCubic(rawT);

      group.position.set(
        lerp(startPos.x, endPos.x, t),
        lerp(startPos.y, endPos.y, t) + (isRolling && !die.selected ? Math.sin(rawT * Math.PI) * 0.45 : 0),
        lerp(startPos.z, endPos.z, t)
      );

      group.rotation.set(
        lerp(startRot.x, endRot.x, t),
        lerp(startRot.y, endRot.y, t),
        lerp(startRot.z, endRot.z, t)
      );

      if (rawT < 1) {
        animationRef.current = requestAnimationFrame(animate);
      } else {
        prevPosition.current = endPos;
        prevRotation.current = endRot;
      }
    };

    animationRef.current = requestAnimationFrame(animate);

    return () => {
      if (animationRef.current) cancelAnimationFrame(animationRef.current);
    };
  }, [die.position, die.rotation, die.selected, isRolling]);

  return (
    <group ref={groupRef} position={die.position} rotation={die.rotation} onClick={() => !isRolling && onToggle(die.id)}>
      <RoundedBox args={[1, 1, 1]} radius={0.1} smoothness={5} castShadow receiveShadow>
        <meshPhysicalMaterial
          color={bodyColor}
          roughness={0.42}
          metalness={0.04}
          clearcoat={0.35}
          clearcoatRoughness={0.35}
          emissive={die.selected ? '#d3a400' : '#000000'}
          emissiveIntensity={die.selected ? 0.14 : 0}
        />
      </RoundedBox>

      {FACE_CONFIG.map((face) => (
        <group key={face.value} position={face.position} rotation={face.rotation}>
          <PipFace value={face.value} />
        </group>
      ))}
    </group>
  );
}

function Tray() {
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

export default function App() {
  const [dice, setDice] = useState(INITIAL_DICE);
  const [rollCount, setRollCount] = useState(0);
  const [isRolling, setIsRolling] = useState(false);

  const diceWithValues = useMemo(
    () => dice.map((die) => ({ ...die, topValue: getTopFace(die.rotation) })),
    [dice]
  );

  const toggleDie = (id: number) => {
    setDice((current) => {
      const toggled = current.map((die) =>
        die.id === id ? { ...die, selected: !die.selected } : die
      );

      const selected = toggled.filter((die) => die.selected).sort((a, b) => a.id - b.id);
      const unselected = toggled.filter((die) => !die.selected).sort((a, b) => a.id - b.id);

      const reflowedSelected = selected.map((die, index) => ({
        ...die,
        basePosition: [-3.6 + index * 1.45, 0.78, -4.45] as [number, number, number],
        position: [-3.6 + index * 1.45, 0.78, -4.45] as [number, number, number],
        rotation: [0, 0, 0] as [number, number, number],
      }));

      const reflowedUnselected = unselected.map((die, index) => {
        const target: [number, number, number] = [-3.75 + index * 1.5, 0.75 + (index % 2) * 0.03, (index % 3) * 0.24 - 0.24];
        return {
          ...die,
          basePosition: target,
          position: target,
          rotation: getFinalRotation(index + 1, die.id),
        };
      });

      return [...reflowedSelected, ...reflowedUnselected].sort((a, b) => a.id - b.id);
    });
  };

  const rollDice = () => {
    if (isRolling) return;
    setRollCount((count) => count + 1);
    setIsRolling(true);

    setDice((current) => {
      const selected = current.filter((die) => die.selected).sort((a, b) => a.id - b.id);
      const unselected = current.filter((die) => !die.selected).sort((a, b) => a.id - b.id);

      const rerolled = unselected.map((die, index) => {
        const finalPosition: [number, number, number] = [
          -3.75 + index * 1.5,
          0.75 + ((index + rollCount) % 2) * 0.05,
          ((index + rollCount) % 3) * 0.32 - 0.32,
        ];
        const launchPosition: [number, number, number] = [
          finalPosition[0] + (index - 2) * 0.6,
          finalPosition[1] + 0.7,
          finalPosition[2] + (index % 2 === 0 ? 0.8 : -0.8),
        ];
        return {
          ...die,
          basePosition: finalPosition,
          position: launchPosition,
          rotation: [
            (rollCount + 1) * 2.7 + index * 1.1,
            (rollCount + 1) * 2.1 + index * 0.9,
            (rollCount + 1) * 2.4 + index * 1.3,
          ] as [number, number, number],
        };
      });

      const banked = selected.map((die, index) => {
        const bankPos: [number, number, number] = [-3.6 + index * 1.45, 0.78, -4.45];
        return {
          ...die,
          basePosition: bankPos,
          position: bankPos,
        };
      });

      return [...banked, ...rerolled].sort((a, b) => a.id - b.id);
    });

    setTimeout(() => {
      setDice((current) =>
        current.map((die, index) =>
          die.selected
            ? die
            : {
                ...die,
                position: die.basePosition,
                rotation: getFinalRotation(rollCount + die.id + 7, index),
              }
        )
      );
    }, 80);

    setTimeout(() => {
      setIsRolling(false);
    }, 760);
  };

  const reset = () => {
    setDice(INITIAL_DICE);
    setRollCount(0);
    setIsRolling(false);
  };

  const selectedDice = diceWithValues.filter((die) => die.selected);
  const activeDice = diceWithValues.filter((die) => !die.selected);

  return (
    <div className="app-shell">
      <div className="hud top">
        <div>
          <h1>Gamble Game Web Spike</h1>
          <p>Arbeitsblock 1B: Face-Mapping, Top-Face-Erkennung und glaubwürdigeres Landen.</p>
        </div>
        <div className="hud-box">
          <strong>Selected Dice:</strong> {selectedDice.length} / 6
          <br />
          <strong>Banked Top Values:</strong> {selectedDice.map((die) => die.topValue).join(', ') || 'none'}
        </div>
      </div>

      <div className="controls">
        <button onClick={rollDice} disabled={isRolling}>{isRolling ? 'Rolling…' : 'Roll Demo'}</button>
        <button onClick={reset} disabled={isRolling}>Reset</button>
      </div>

      <div className="hint-panel">
        <strong>Spike-Fokus:</strong> echte Würfelseiten, Top-Face-Erkennung und ein Wurf, der sich wenigstens wie Würfeln statt Teleport anfühlt.
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
        <Tray />
        {dice.map((die) => (
          <Die key={die.id} die={die} onToggle={toggleDie} isRolling={isRolling} />
        ))}
        <ContactShadows position={[0, 0.12, 0]} opacity={0.5} scale={20} blur={2.4} far={10} />
        <OrbitControls enablePan={false} minPolarAngle={0.75} maxPolarAngle={1.25} minDistance={8.5} maxDistance={14} />
      </Canvas>
    </div>
  );
}
