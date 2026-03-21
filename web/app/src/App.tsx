import { Canvas } from '@react-three/fiber';
import { OrbitControls, RoundedBox, ContactShadows } from '@react-three/drei';
import { useMemo, useState } from 'react';
import * as THREE from 'three';

type DieState = {
  id: number;
  position: [number, number, number];
  selected: boolean;
  hue: number;
};

const INITIAL_DICE: DieState[] = [
  { id: 1, position: [-3.75, 0.6, 0], selected: false, hue: 0.08 },
  { id: 2, position: [-2.25, 0.6, 0], selected: false, hue: 0.1 },
  { id: 3, position: [-0.75, 0.6, 0], selected: false, hue: 0.12 },
  { id: 4, position: [0.75, 0.6, 0], selected: false, hue: 0.14 },
  { id: 5, position: [2.25, 0.6, 0], selected: false, hue: 0.16 },
  { id: 6, position: [3.75, 0.6, 0], selected: false, hue: 0.18 },
];

function Die({ die, onToggle }: { die: DieState; onToggle: (id: number) => void }) {
  const color = useMemo(() => new THREE.Color().setHSL(die.hue, 0.55, die.selected ? 0.7 : 0.9), [die.hue, die.selected]);

  return (
    <group position={die.position} onClick={() => onToggle(die.id)}>
      <RoundedBox args={[1, 1, 1]} radius={0.08} smoothness={4} castShadow receiveShadow>
        <meshStandardMaterial color={color} metalness={0.05} roughness={0.35} emissive={die.selected ? '#6dff8a' : '#000000'} emissiveIntensity={die.selected ? 0.35 : 0} />
      </RoundedBox>
    </group>
  );
}

function Tray() {
  return (
    <group>
      <mesh receiveShadow position={[0, 0, 0]}>
        <boxGeometry args={[11, 0.25, 11]} />
        <meshStandardMaterial color="#6e1414" roughness={0.95} metalness={0.02} />
      </mesh>
      <mesh receiveShadow position={[0, 0.6, -5.4]}>
        <boxGeometry args={[11.4, 1.2, 1.4]} />
        <meshStandardMaterial color="#161616" roughness={0.75} metalness={0.2} />
      </mesh>
      <mesh receiveShadow position={[0, 0.7, 5.15]}>
        <boxGeometry args={[10.4, 1.4, 0.3]} />
        <meshStandardMaterial color="#121212" roughness={0.8} metalness={0.15} />
      </mesh>
      <mesh receiveShadow position={[-5.15, 0.7, 0]}>
        <boxGeometry args={[0.3, 1.4, 10.3]} />
        <meshStandardMaterial color="#121212" roughness={0.8} metalness={0.15} />
      </mesh>
      <mesh receiveShadow position={[5.15, 0.7, 0]}>
        <boxGeometry args={[0.3, 1.4, 10.3]} />
        <meshStandardMaterial color="#121212" roughness={0.8} metalness={0.15} />
      </mesh>
    </group>
  );
}

export default function App() {
  const [dice, setDice] = useState(INITIAL_DICE);
  const [rollCount, setRollCount] = useState(0);

  const toggleDie = (id: number) => {
    setDice((current) => {
      const toggled = current.map((die) =>
        die.id === id ? { ...die, selected: !die.selected } : die
      );

      const selected = toggled.filter((die) => die.selected);
      const unselected = toggled.filter((die) => !die.selected);

      const reflowedSelected = selected.map((die, index) => ({
        ...die,
        position: [-3.75 + index * 1.5, 1.65, -5.35] as [number, number, number],
      }));

      const reflowedUnselected = unselected.map((die, index) => ({
        ...die,
        position: [-3.75 + index * 1.5, 0.6, 0] as [number, number, number],
      }));

      return [...reflowedSelected, ...reflowedUnselected].sort((a, b) => a.id - b.id);
    });
  };

  const rollDice = () => {
    setRollCount((count) => count + 1);
    setDice((current) => {
      const selectedCount = current.filter((die) => die.selected).length;
      return current.map((die, index) => {
        if (die.selected) return die;
        const offset = index - selectedCount;
        return {
          ...die,
          position: [
            -3.75 + Math.max(offset, 0) * 1.5,
            0.6 + ((index + rollCount) % 2) * 0.15,
            ((index + rollCount) % 3) * 0.2 - 0.2,
          ],
        };
      });
    });
  };

  const reset = () => {
    setDice(INITIAL_DICE);
    setRollCount(0);
  };

  const selectedCount = dice.filter((die) => die.selected).length;

  return (
    <div className="app-shell">
      <div className="hud top">
        <div>
          <h1>Gamble Game Web Spike</h1>
          <p>Arbeitsblock 1: R3F-Renderer prüfen, nicht Weltfrieden.</p>
        </div>
        <div className="hud-box">
          <strong>Selected Dice:</strong> {selectedCount} / 6
          <br />
          <strong>Roll Demo Count:</strong> {rollCount}
        </div>
      </div>

      <div className="controls">
        <button onClick={rollDice}>Roll Demo</button>
        <button onClick={reset}>Reset</button>
      </div>

      <div className="hint-panel">
        <strong>Spike-Ziel:</strong> Tray, sechs Würfel, Auswahl, Reorganisation, Grundgefühl.
      </div>

      <Canvas shadows camera={{ position: [0, 8.5, 9], fov: 42 }}>
        <color attach="background" args={['#294331']} />
        <fog attach="fog" args={['#294331', 10, 24]} />
        <ambientLight intensity={1.25} />
        <directionalLight position={[6, 12, 5]} intensity={2.3} castShadow shadow-mapSize-width={2048} shadow-mapSize-height={2048} />
        <pointLight position={[-5, 8, -2]} intensity={14} color="#ffe4b5" />
        <Tray />
        {dice.map((die) => (
          <Die key={die.id} die={die} onToggle={toggleDie} />
        ))}
        <ContactShadows position={[0, 0.13, 0]} opacity={0.5} scale={20} blur={2.2} far={10} />
        <OrbitControls enablePan={false} minPolarAngle={0.75} maxPolarAngle={1.35} minDistance={9} maxDistance={14} />
      </Canvas>
    </div>
  );
}
