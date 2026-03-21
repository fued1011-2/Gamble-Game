import { Canvas } from '@react-three/fiber';
import { ContactShadows, OrbitControls, RoundedBox } from '@react-three/drei';
import { useMemo, useState } from 'react';
import * as THREE from 'three';

type DieState = {
  id: number;
  position: [number, number, number];
  rotation: [number, number, number];
  selected: boolean;
  value: 1 | 2 | 3 | 4 | 5 | 6;
};

const INITIAL_DICE: DieState[] = [
  { id: 1, position: [-3.75, 0.75, 0.35], rotation: [0.12, 0.3, -0.18], selected: false, value: 1 },
  { id: 2, position: [-2.25, 0.72, -0.25], rotation: [-0.2, -0.45, 0.2], selected: false, value: 2 },
  { id: 3, position: [-0.75, 0.74, 0.1], rotation: [0.35, 0.15, -0.28], selected: false, value: 3 },
  { id: 4, position: [0.75, 0.76, -0.18], rotation: [-0.1, 0.4, 0.25], selected: false, value: 4 },
  { id: 5, position: [2.25, 0.73, 0.24], rotation: [0.22, -0.2, 0.42], selected: false, value: 5 },
  { id: 6, position: [3.75, 0.71, -0.08], rotation: [-0.32, 0.22, -0.2], selected: false, value: 6 },
];

const FACE_OFFSETS: Record<number, [number, number][]> = {
  1: [[0, 0]],
  2: [[-0.22, -0.22], [0.22, 0.22]],
  3: [[-0.24, -0.24], [0, 0], [0.24, 0.24]],
  4: [[-0.22, -0.22], [0.22, -0.22], [-0.22, 0.22], [0.22, 0.22]],
  5: [[-0.22, -0.22], [0.22, -0.22], [0, 0], [-0.22, 0.22], [0.22, 0.22]],
  6: [[-0.22, -0.25], [0.22, -0.25], [-0.22, 0], [0.22, 0], [-0.22, 0.25], [0.22, 0.25]],
};

function PipFace({ value }: { value: 1 | 2 | 3 | 4 | 5 | 6 }) {
  return (
    <group position={[0, 0, 0.505]}>
      {FACE_OFFSETS[value].map(([x, y], index) => (
        <mesh key={`${value}-${index}`} position={[x, y, 0]}>
          <circleGeometry args={[0.075, 20]} />
          <meshStandardMaterial color="#141414" roughness={0.35} metalness={0.1} />
        </mesh>
      ))}
    </group>
  );
}

function Die({ die, onToggle }: { die: DieState; onToggle: (id: number) => void }) {
  const bodyColor = die.selected ? '#fff4ba' : '#f7f1df';

  return (
    <group position={die.position} rotation={die.rotation} onClick={() => onToggle(die.id)}>
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
      <PipFace value={die.value} />
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

function valueFromRoll(seed: number) {
  return (((seed % 6) + 6) % 6) + 1 as 1 | 2 | 3 | 4 | 5 | 6;
}

export default function App() {
  const [dice, setDice] = useState(INITIAL_DICE);
  const [rollCount, setRollCount] = useState(0);

  const toggleDie = (id: number) => {
    setDice((current) => {
      const toggled = current.map((die) =>
        die.id === id ? { ...die, selected: !die.selected } : die
      );

      const selected = toggled.filter((die) => die.selected).sort((a, b) => a.id - b.id);
      const unselected = toggled.filter((die) => !die.selected).sort((a, b) => a.id - b.id);

      const reflowedSelected = selected.map((die, index) => ({
        ...die,
        position: [-3.6 + index * 1.45, 0.78, -4.45] as [number, number, number],
        rotation: [0, 0, 0] as [number, number, number],
      }));

      const reflowedUnselected = unselected.map((die, index) => ({
        ...die,
        position: [-3.75 + index * 1.5, 0.75 + (index % 2) * 0.03, (index % 3) * 0.24 - 0.24] as [number, number, number],
        rotation: [
          ((index + 1) * 0.18) % 0.5,
          ((index + 2) * -0.21) % 0.5,
          ((index + 3) * 0.16) % 0.5,
        ] as [number, number, number],
      }));

      return [...reflowedSelected, ...reflowedUnselected].sort((a, b) => a.id - b.id);
    });
  };

  const rollDice = () => {
    setRollCount((count) => count + 1);
    setDice((current) => {
      const selected = current.filter((die) => die.selected).sort((a, b) => a.id - b.id);
      const unselected = current.filter((die) => !die.selected).sort((a, b) => a.id - b.id);

      const rerolled = unselected.map((die, index) => ({
        ...die,
        value: valueFromRoll(die.id + rollCount + index + 1),
        position: [
          -3.75 + index * 1.5,
          0.75 + ((index + rollCount) % 2) * 0.05,
          ((index + rollCount) % 3) * 0.32 - 0.32,
        ] as [number, number, number],
        rotation: [
          ((rollCount + 1) * 0.7 + index * 0.15) % Math.PI,
          ((rollCount + 1) * -0.45 + index * 0.22) % Math.PI,
          ((rollCount + 1) * 0.35 + index * 0.31) % Math.PI,
        ] as [number, number, number],
      }));

      const banked = selected.map((die, index) => ({
        ...die,
        position: [-3.6 + index * 1.45, 0.78, -4.45] as [number, number, number],
        rotation: [0, 0, 0] as [number, number, number],
      }));

      return [...banked, ...rerolled].sort((a, b) => a.id - b.id);
    });
  };

  const reset = () => {
    setDice(INITIAL_DICE);
    setRollCount(0);
  };

  const selectedCount = dice.filter((die) => die.selected).length;
  const selectedValues = useMemo(
    () => dice.filter((die) => die.selected).map((die) => die.value).join(', ') || 'none',
    [dice]
  );

  return (
    <div className="app-shell">
      <div className="hud top">
        <div>
          <h1>Gamble Game Web Spike</h1>
          <p>Arbeitsblock 1: Renderer und Grundgefühl absichern.</p>
        </div>
        <div className="hud-box">
          <strong>Selected Dice:</strong> {selectedCount} / 6
          <br />
          <strong>Banked Values:</strong> {selectedValues}
        </div>
      </div>

      <div className="controls">
        <button onClick={rollDice}>Roll Demo</button>
        <button onClick={reset}>Reset</button>
      </div>

      <div className="hint-panel">
        <strong>Spike-Ziel:</strong> hochwertiger Tray-Eindruck, klarere Würfel, Banking-Zone und saubere Interaktion.
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
          <Die key={die.id} die={die} onToggle={toggleDie} />
        ))}
        <ContactShadows position={[0, 0.12, 0]} opacity={0.5} scale={20} blur={2.4} far={10} />
        <OrbitControls enablePan={false} minPolarAngle={0.75} maxPolarAngle={1.25} minDistance={8.5} maxDistance={14} />
      </Canvas>
    </div>
  );
}
