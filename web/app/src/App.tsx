import { Canvas } from '@react-three/fiber';
import { ContactShadows, OrbitControls } from '@react-three/drei';
import { Physics } from '@react-three/rapier';
import { useMemo, useState } from 'react';
import { DiceCup } from './components/DiceCup';
import { PhysicsDie } from './components/PhysicsDie';
import { CupColliders, TrayColliders, TrayVisual } from './components/Tray';
import { CUP_INTERIOR_POINTS, CUP_POSITION, INITIAL_DICE } from './constants/dice';
import type { DieSeed, FaceValue, RollPhase } from './types/dice';

export default function App() {
  const [dice, setDice] = useState<DieSeed[]>(INITIAL_DICE);
  const [rollCount, setRollCount] = useState(0);
  const [isRolling, setIsRolling] = useState(false);
  const [rollPhase, setRollPhase] = useState<RollPhase>('idle');
  const [detectedValues, setDetectedValues] = useState<Record<number, FaceValue>>({
    1: 1,
    2: 1,
    3: 1,
    4: 1,
    5: 1,
    6: 1,
  });

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
        position: [-3.3 + index * 1.1, 0.88, -4.45] as [number, number, number],
      }));

      const reflowedUnselected = unselected.map((die, index) => {
        const point = CUP_INTERIOR_POINTS[index % CUP_INTERIOR_POINTS.length];
        return {
          ...die,
          position: [
            CUP_POSITION[0] + point[0],
            CUP_POSITION[1] - 1.24 + point[1],
            CUP_POSITION[2] + point[2],
          ] as [number, number, number],
          placementKey: `cup-load-${die.id}-${index}`,
        };
      });

      return [...reflowedSelected, ...reflowedUnselected].sort((a, b) => a.id - b.id);
    });
  };

  /**
   * Der Referenz-Wurf wird als Choreografie behandelt:
   * loading -> pouring -> settling.
   * Ziel ist nicht maximale Chaos-Physik, sondern ein glaubwürdiger, lesbarer Dice Flow.
   */
  const rollDice = () => {
    if (isRolling) return;

    setIsRolling(true);
    setRollPhase('loading');
    setRollCount((count) => count + 1);

    setDice((current) =>
      current.map((die, index) => {
        if (die.selected) return die;
        const point = CUP_INTERIOR_POINTS[index % CUP_INTERIOR_POINTS.length];
        return {
          ...die,
          position: [
            CUP_POSITION[0] + point[0],
            CUP_POSITION[1] - 1.24 + point[1],
            CUP_POSITION[2] + point[2],
          ] as [number, number, number],
          placementKey: `cup-load-roll-${rollCount + 1}-${die.id}-${index}`,
        };
      })
    );

    setTimeout(() => {
      setRollPhase('pouring');
      setDice((current) =>
        current.map((die, index) => {
          if (die.selected) return die;
          return {
            ...die,
            position: [
              CUP_POSITION[0] + (index - 2.5) * 0.06,
              CUP_POSITION[1] - 1.06 + (index % 2) * 0.03,
              CUP_POSITION[2] - 2.55 + ((index % 3) - 1) * 0.06,
            ] as [number, number, number],
            placementKey: `cup-pour-${rollCount + 1}-${die.id}-${index}`,
          };
        })
      );
    }, 760);

    setTimeout(() => {
      setRollPhase('settling');
    }, 1500);

    setTimeout(() => {
      setRollPhase('idle');
      setIsRolling(false);
    }, 2650);
  };

  const reset = () => {
    setDice(INITIAL_DICE);
    setRollCount(0);
    setIsRolling(false);
    setRollPhase('idle');
    setDetectedValues({ 1: 1, 2: 1, 3: 1, 4: 1, 5: 1, 6: 1 });
  };

  const selectedDice = useMemo(
    () => dice.filter((die) => die.selected).map((die) => ({ ...die, topValue: detectedValues[die.id] })),
    [dice, detectedValues]
  );

  const activeDice = useMemo(
    () => dice.filter((die) => !die.selected).map((die) => ({ ...die, topValue: detectedValues[die.id] })),
    [dice, detectedValues]
  );

  return (
    <div className="app-shell">
      <div className="hud top">
        <div>
          <h1>Gamble Game Web Spike</h1>
          <p>Arbeitsblock 1I: stärker choreografierter Referenz-Wurf mit kontrollierter Freigabe aus dem Becher.</p>
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
        <strong>Spike-Fokus:</strong> aktive Würfel kontrolliert im Becher sammeln, sichtbar ausgießen und mit lesbaren Endlagen im Tray landen lassen.
      </div>

      <div className="value-panel">
        <div><strong>Active Top Values:</strong> {activeDice.map((die) => die.topValue).join(', ') || 'none'}</div>
        <div><strong>Detected Total:</strong> {activeDice.reduce((sum, die) => sum + die.topValue, 0)}</div>
      </div>

      <Canvas shadows camera={{ position: [0, 10.8, 13.8], fov: 32 }}>
        <color attach="background" args={['#21382c']} />
        <fog attach="fog" args={['#21382c', 10, 24]} />
        <ambientLight intensity={1.18} />
        <directionalLight position={[6, 12, 5]} intensity={2.5} castShadow shadow-mapSize-width={2048} shadow-mapSize-height={2048} />
        <pointLight position={[-4.5, 7, -2.5]} intensity={13} color="#ffd9a0" />
        <pointLight position={[4.5, 5.5, 3.5]} intensity={7} color="#b8d7ff" />

        <DiceCup rollPhase={rollPhase} />
        <Physics gravity={[0, -12, 0]}>
          <TrayColliders />
          <CupColliders />
          {dice.map((die) => (
            <PhysicsDie
              key={`${die.id}-${rollCount}`}
              die={die}
              onToggle={toggleDie}
              onValueChange={updateDetectedValue}
              isRolling={isRolling}
              rollPhase={rollPhase}
            />
          ))}
        </Physics>
        <TrayVisual />
        <ContactShadows position={[0, 0.12, 0]} opacity={0.5} scale={20} blur={2.4} far={10} />
        <OrbitControls enablePan={false} minPolarAngle={0.72} maxPolarAngle={1.18} minDistance={10.5} maxDistance={20} />
      </Canvas>
    </div>
  );
}
