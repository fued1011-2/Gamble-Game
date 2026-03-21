import { Canvas } from '@react-three/fiber';
import { ContactShadows, OrbitControls } from '@react-three/drei';
import { Physics } from '@react-three/rapier';
import { useEffect, useMemo, useRef, useState } from 'react';
import { DiceCup } from './components/DiceCup';
import { PhysicsDie } from './components/PhysicsDie';
import { CupColliders, TrayColliders, TrayVisual } from './components/Tray';
import { CUP_INTERIOR_POINTS, CUP_POSITION, INITIAL_DICE } from './constants/dice';
import { ACTIVE_SETTLE_POSITIONS, KEEP_SETTLE_POSITIONS } from './constants/layout';
import type { DieSeed, FaceValue, RollPhase } from './types/dice';

export default function App() {
  const [dice, setDice] = useState<DieSeed[]>(INITIAL_DICE);
  const [rollCount, setRollCount] = useState(0);
  const [isRolling, setIsRolling] = useState(false);
  const [rollPhase, setRollPhase] = useState<RollPhase>('idle');
  const [settledIds, setSettledIds] = useState<number[]>([]);
  const settleStartedAtRef = useRef<number | null>(null);
  const finalizeTimeoutRef = useRef<number | null>(null);
  const forcedSettleTimeoutRef = useRef<number | null>(null);
  const settlingTriggeredRef = useRef(false);
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

  const markDieSettled = (id: number) => {
    setSettledIds((current) => (current.includes(id) ? current : [...current, id]));
  };

  const clearTimers = () => {
    if (finalizeTimeoutRef.current !== null) {
      window.clearTimeout(finalizeTimeoutRef.current);
      finalizeTimeoutRef.current = null;
    }
    if (forcedSettleTimeoutRef.current !== null) {
      window.clearTimeout(forcedSettleTimeoutRef.current);
      forcedSettleTimeoutRef.current = null;
    }
  };

  const toggleDie = (id: number) => {
    if (isRolling) return;

    setDice((current) => {
      const toggled = current.map((die) => (die.id === id ? { ...die, selected: !die.selected } : die));
      const selected = toggled.filter((die) => die.selected).sort((a, b) => a.id - b.id);
      const unselected = toggled.filter((die) => !die.selected).sort((a, b) => a.id - b.id);

      const reflowedSelected = selected.map((die, index) => ({
        ...die,
        position: KEEP_SETTLE_POSITIONS[index % KEEP_SETTLE_POSITIONS.length],
        placementKey: `selected-${rollCount}-${die.id}-${index}`,
      }));

      const reflowedUnselected = unselected.map((die, index) => ({
        ...die,
        position: ACTIVE_SETTLE_POSITIONS[index % ACTIVE_SETTLE_POSITIONS.length],
        placementKey: `active-select-${rollCount}-${die.id}-${index}`,
      }));

      return [...reflowedSelected, ...reflowedUnselected].sort((a, b) => a.id - b.id);
    });
  };

  const finalizeRoll = (nextRoll: number) => {
    if (settlingTriggeredRef.current) return;
    settlingTriggeredRef.current = true;
    clearTimers();

    setRollPhase('settling');
    setDice((current) => {
      const selected = current.filter((die) => die.selected).sort((a, b) => a.id - b.id);
      const unselected = current.filter((die) => !die.selected).sort((a, b) => a.id - b.id);

      const kept = selected.map((die, index) => ({
        ...die,
        position: KEEP_SETTLE_POSITIONS[index % KEEP_SETTLE_POSITIONS.length],
        placementKey: `settled-selected-${nextRoll}-${die.id}-${index}`,
      }));

      const active = unselected.map((die, index) => ({
        ...die,
        position: ACTIVE_SETTLE_POSITIONS[index % ACTIVE_SETTLE_POSITIONS.length],
        placementKey: `settled-active-${nextRoll}-${die.id}-${index}`,
      }));

      return [...kept, ...active].sort((a, b) => a.id - b.id);
    });

    finalizeTimeoutRef.current = window.setTimeout(() => {
      setRollPhase('idle');
      setIsRolling(false);
      finalizeTimeoutRef.current = null;
    }, 900);
  };

  const rollDice = () => {
    if (isRolling) return;

    const nextRoll = rollCount + 1;
    setRollCount(nextRoll);
    setIsRolling(true);
    setRollPhase('loading');
    setSettledIds([]);
    settleStartedAtRef.current = null;
    settlingTriggeredRef.current = false;
    clearTimers();

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
          placementKey: `cup-load-roll-${nextRoll}-${die.id}-${index}`,
        };
      })
    );

    window.setTimeout(() => {
      settleStartedAtRef.current = Date.now();
      setRollPhase('pouring');
      setDice((current) =>
        current.map((die, index) => {
          if (die.selected) return die;
          return {
            ...die,
            position: [
              3.55 + (index % 2) * 0.48 - (index > 3 ? 0.22 : 0),
              3.88 + (index % 3) * 0.07,
              0.85 - index * 0.42,
            ] as [number, number, number],
            placementKey: `cup-pour-${nextRoll}-${die.id}-${index}`,
          };
        })
      );

      forcedSettleTimeoutRef.current = window.setTimeout(() => {
        finalizeRoll(nextRoll);
      }, 4200);
    }, 760);
  };

  useEffect(() => {
    if (rollPhase !== 'pouring') return;
    if (settlingTriggeredRef.current) return;

    const activeIds = dice.filter((die) => !die.selected).map((die) => die.id);
    if (activeIds.length === 0) return;

    const allSettled = activeIds.every((id) => settledIds.includes(id));
    const minDelayReached =
      settleStartedAtRef.current !== null && Date.now() - settleStartedAtRef.current > 1700;

    if (!allSettled || !minDelayReached) return;
    finalizeRoll(rollCount);
  }, [rollPhase, settledIds, dice, rollCount]);

  const reset = () => {
    clearTimers();
    setDice(INITIAL_DICE);
    setRollCount(0);
    setIsRolling(false);
    setRollPhase('idle');
    setSettledIds([]);
    settleStartedAtRef.current = null;
    settlingTriggeredRef.current = false;
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
          <p>Arbeitsblock 3F: Tischkomposition korrigieren – Kamera weiter raus, Becher und Würfel kleiner.</p>
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
        <strong>Aktueller Fokus:</strong> Kamera weiter zurücknehmen und Becher/Würfel auf eine glaubwürdigere Tischskala bringen.
      </div>

      <div className="value-panel">
        <div><strong>Active Top Values:</strong> {activeDice.map((die) => die.topValue).join(', ') || 'none'}</div>
        <div><strong>Detected Total:</strong> {activeDice.reduce((sum, die) => sum + die.topValue, 0)}</div>
      </div>

      <Canvas shadows camera={{ position: [0, 20.6, 8.8], fov: 22 }}>
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
              onSettled={markDieSettled}
              isRolling={isRolling}
              rollPhase={rollPhase}
            />
          ))}
        </Physics>
        <TrayVisual />
        <ContactShadows position={[0, 0.12, 0]} opacity={0.36} scale={21} blur={3.1} far={10} />
        <OrbitControls enablePan={false} target={[0, 0.7, -0.55]} minPolarAngle={0.3} maxPolarAngle={0.5} minDistance={16} maxDistance={24} />
      </Canvas>
    </div>
  );
}
