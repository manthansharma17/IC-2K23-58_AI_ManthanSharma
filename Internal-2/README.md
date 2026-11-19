# Intelligent Timetable Generator — Turbo Prolog

A Prolog program that builds a **clash-free college timetable**. It assigns each subject's lectures to available slots and rooms, and if no valid timetable exists, it explains why.

**Concepts:** constraint satisfaction, backtracking, knowledge representation

🎥 **Video demo:** [Watch on YouTube](https://youtu.be/FsdrNRH_kB4)

---

## Files

| File | Purpose |
|---|---|
| `TP/TIMETBL.PRO` | Source code |
| `Start Turbo Prolog.bat` | Launches DOSBox + Turbo Prolog |
| `tprolog.conf` | DOSBox settings |

## How to Run

1. Double-click **`Start Turbo Prolog.bat`**. If Windows warns you, click *More info → Run anyway*.
2. Press **Esc**, then **F → L**, type `TIMETBL`, and press **Enter**.
3. Press **R** to run.
4. Type all input in **lowercase**.

| Menu | Action |
|---|---|
| `1` | Generate the timetable |
| `2` | Mark a teacher unavailable for a slot |
| `3` | Change the number of lectures for a subject |
| `4` | Show the current facts |
| `0` | Exit |

Press **Esc → R** to reset to the original data before each test.

---

## Knowledge Representation (Facts)

| Subject | Teacher | Lectures | Type |
|---|---|---|---|
| ai | teacher_a | 2 | theory |
| python | teacher_b | 2 | practical |
| dbms | teacher_c | 1 | theory |

| Room | Type |
|---|---|
| r101 | classroom |
| r102 | lab |

**Slots:** Monday 9 AM, Monday 10 AM, Tuesday 9 AM, Tuesday 10 AM, Wednesday 9 AM

| Fact | Meaning |
|---|---|
| `subject(Name, Teacher, Lectures, Type)` | Subject–teacher assignment (in `database`, so it can be changed at run time) |
| `room(Id, Type)` | Available rooms |
| `slot(Id, Label)` | Available time slots |
| `next(Slot1, Slot2)` | Slots that are back to back on the same day |
| `room_ok(SubjectType, RoomType)` | Practical → lab, theory → classroom |
| `room_blocked(Room, Slot)` | Room availability (r102 is blocked on Wednesday 9 AM) |
| `teacher_unavailable(Teacher, Slot)` | Added at run time from menu option 2 |

## Constraints (Rules)

| Rule | Constraint |
|---|---|
| `teacher_busy/3` | A teacher is never in two classes in the same slot |
| `room_busy/3` | A room never holds two classes in the same slot |
| `slot_used/2` | The class attends only one lecture per slot |
| `teacher_unavailable/2` | A teacher is never scheduled in a slot they marked unavailable |
| `room_blocked/2` | A blocked room is never used |
| `back_to_back/3` | The same subject is never in consecutive slots |
| `room_ok/2` | Practical subjects go in the lab, theory subjects in the classroom |
| `expand/2` | Every subject gets exactly its required number of lectures |

## Approach

1. **Expand** each subject into individual lectures (AI × 2 becomes `[ai, ai]`).
2. **Prioritise:** practical subjects are placed first.
3. **Schedule recursively:** for each lecture, pick a slot and a room, then check every constraint.
4. **Backtrack:** if a later lecture can't be placed, Prolog automatically undoes earlier choices and tries other options.
5. **Report:** print the timetable in slot order, or explain the failure with `why_failed`:
   - more lectures than slots, or
   - the availability, room type or no-consecutive rule cannot all be satisfied.

---

## Test Cases

Run each on a fresh start (**Esc → R**).

### 1. Sample input
Input: `1`
```
GENERATED TIMETABLE

Monday 9 AM    : python | teacher_b | r102
Monday 10 AM   : ai | teacher_a | r101
Tuesday 9 AM   : python | teacher_b | r102
Tuesday 10 AM  : ai | teacher_a | r101
Wednesday 9 AM : dbms | teacher_c | r101

Status: Timetable generated without teacher or room clashes.
```

### 2. Teacher unavailable
Input: `2` → `teacher_a` → `mon_10am`, then `1`
```
Monday 9 AM    : python | teacher_b | r102
Monday 10 AM   : dbms | teacher_c | r101
Tuesday 9 AM   : python | teacher_b | r102
Tuesday 10 AM  : ai | teacher_a | r101
Wednesday 9 AM : ai | teacher_a | r101
```
Backtracking moves AI away from Monday 10 AM, and DBMS takes that slot.

### 3. No valid timetable
Input: `3` → `dbms` → `2`, then `1`
```
Status: NO valid timetable could be created.
Reason: 6 lectures needed but only 5 slots exist.
```

---

## Quick Modifications (for the viva)

| Change | Edit |
|---|---|
| Add a slot | `slot(wed_10am, "Wednesday 10 AM").` (fixes test 3) |
| Add a subject | `subject(os, teacher_d, 1, theory).` |
| Block a room | `room_blocked(r101, mon_9am).` |
| Make two slots consecutive | `next(tue_10am, wed_9am).` |
| Teacher unavailable in code | Add `teacher_unavailable(teacher_b, mon_9am).` under the `room_blocked` fact |

Edit: **Esc → E**, make the change, **F2** to save, **Esc → R** to run.
