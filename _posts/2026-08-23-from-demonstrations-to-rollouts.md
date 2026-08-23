---
title: "From Demonstrations to Rollouts: What Robot Data Actually Matters?"
date: 2026-08-23 15:29:00 +0800
categories: [Robotics, Simulation]
tags: [robotics, simulation, robot-learning, synthetic-data, imitation-learning, policy-evaluation]
math: true
toc: true
description: "Expert demonstrations teach desired behavior. Target-policy rollouts reveal the states a robot actually visits. Simulation can scale both—but they answer different questions."
image:
  path: /assets/img/from-demonstrations-to-rollouts/from-demonstrations-to-rollouts-hero.webp
  alt: A two-axis map of robot data, separating expert from target-policy actions and real from simulated worlds
---

A simulator can construct worlds, generate behavior, and test robot policies.
An [earlier overview][simulation-data-engines] describes that machinery.

So, **what robot data should simulation generate?**

The key distinction is not simply real versus synthetic, or human
versus robot. It is **who chose the actions that produced the visited states**.
Expert demonstrations show competent behavior. Target-policy rollouts show what
the policy itself does: where it goes, how mistakes compound, and whether it
recovers.

The sources complement each other; simulation can scale both. But a
simulated target-policy rollout is trustworthy only when its feedback loop
preserves behavior relevant to the intended use.

## 1. The pyramid hides several questions

The robot-data pyramid captures an economic pattern: internet and egocentric
video are abundant; robot-grounded demonstrations require specialized hardware
and labor; autonomous deployment data requires a safe, competent policy.

[GR00T N1][groot-data] presents three layers; [Tanay Jaipuria][data-pyramid]
expands the picture to seven source types; and a recent [embodied-manipulation
survey][embodied-pyramid] separates alignment, quality, diversity, reusability,
and physical fidelity. Varun Nair's public [“Robotics Data Map”
sketch][robotics-data-map] also inspired the actor-versus-substrate distinction,
but is not evidence for the technical claims below.

<style>
  .rollout-bridge-figure { display: block; width: 100%; border: 0; }
  .rollout-bridge-figure--mobile { display: none; }
  .rollout-bridge-pyramids--desktop { aspect-ratio: 1200 / 690; }
  .rollout-bridge-pyramids--mobile { aspect-ratio: 720 / 1608; }
  .rollout-bridge-profile--desktop { aspect-ratio: 1200 / 1080; }
  .rollout-bridge-profile--mobile { aspect-ratio: 720 / 2340; }
  .rollout-bridge-map--desktop { aspect-ratio: 1200 / 880; }
  .rollout-bridge-map--mobile { aspect-ratio: 720 / 1580; }
  .rollout-bridge-loop--desktop { aspect-ratio: 1200 / 780; }
  .rollout-bridge-loop--mobile { aspect-ratio: 720 / 1260; }
  .rollout-bridge-learning-stage { aspect-ratio: 16 / 9; border-radius: 1rem; overflow: hidden; }
  .table-wrapper > table.rollout-comparison-table,
  .table-wrapper > table.rollout-notation-table,
  .table-wrapper > table.rollout-value-factor-table {
    width: 100% !important;
    min-width: 0 !important;
    table-layout: fixed;
  }
  .table-wrapper > table.rollout-comparison-table thead th,
  .table-wrapper > table.rollout-comparison-table tbody tr th,
  .table-wrapper > table.rollout-comparison-table tbody tr td,
  .table-wrapper > table.rollout-notation-table thead th,
  .table-wrapper > table.rollout-notation-table tbody tr th,
  .table-wrapper > table.rollout-notation-table tbody tr td,
  .table-wrapper > table.rollout-value-factor-table thead th,
  .table-wrapper > table.rollout-value-factor-table tbody tr th,
  .table-wrapper > table.rollout-value-factor-table tbody tr td {
    white-space: normal !important;
    vertical-align: top;
    overflow-wrap: anywhere;
  }
  .table-wrapper > table.rollout-value-factor-table th:first-child,
  .table-wrapper > table.rollout-value-factor-table td:first-child {
    width: 14%;
  }
  .table-wrapper > table.rollout-notation-table th:first-child,
  .table-wrapper > table.rollout-notation-table td:first-child {
    width: 40%;
  }
  #copy-link:focus-visible,
  #back-to-top:focus-visible,
  .mode-toggle:focus-visible {
    outline: 3px solid var(--link-color) !important;
    outline-offset: 3px;
    box-shadow: none !important;
  }
  @media screen and (max-width: 575px) {
    .rollout-bridge-figure--desktop { display: none; }
    .rollout-bridge-figure--mobile { display: block; }
    .table-wrapper > table.rollout-notation-table,
    .table-wrapper > table.rollout-notation-table tbody,
    .table-wrapper > table.rollout-notation-table tr,
    .table-wrapper > table.rollout-notation-table th,
    .table-wrapper > table.rollout-notation-table td {
      display: block;
      width: 100% !important;
    }
    .table-wrapper > table.rollout-notation-table thead {
      position: absolute;
      width: 1px;
      height: 1px;
      padding: 0;
      margin: -1px;
      overflow: hidden;
      clip: rect(0, 0, 0, 0);
      white-space: nowrap;
      border: 0;
    }
    .table-wrapper > table.rollout-notation-table tr {
      padding: .3rem 0;
      border-bottom: 1px solid var(--main-border-color);
    }
    .table-wrapper > table.rollout-notation-table :is(th, td):first-child {
      padding-bottom: .15rem;
      font-weight: 600;
    }
    .table-wrapper > table.rollout-notation-table td:last-child {
      padding-top: .15rem;
    }
  }
  @media print {
    .rollout-bridge-figure--desktop { display: block; }
    .rollout-bridge-figure--mobile { display: none; }
  }
</style>

<script>
  document.addEventListener('DOMContentLoaded', () => {
    const backToTop = document.getElementById('back-to-top');
    if (backToTop && !backToTop.hasAttribute('aria-label')) {
      backToTop.setAttribute('aria-label', 'Scroll to top');
    }

    document.querySelectorAll('table.rollout-a11y-table').forEach((table) => {
      table.querySelectorAll('thead th').forEach((header) => {
        header.setAttribute('scope', 'col');
      });
      if (!table.querySelector('caption')) {
        const caption = document.createElement('caption');
        caption.className = 'visually-hidden';
        caption.textContent = table.getAttribute('aria-label');
        table.prepend(caption);
      }
    });

    document.querySelectorAll('table.rollout-row-header-table tbody tr').forEach((row) => {
      const cell = row.querySelector('td:first-child');
      if (cell) {
        const header = document.createElement('th');
        header.setAttribute('scope', 'row');
        header.innerHTML = cell.innerHTML;
        cell.replaceWith(header);
      }
    });
  });
</script>

<object class="rollout-bridge-figure rollout-bridge-figure--desktop rollout-bridge-pyramids--desktop" data="/assets/img/from-demonstrations-to-rollouts/published-pyramid-views.svg" type="image/svg+xml" role="img" aria-label="Three simplified published robot-data pyramids: GR00T N1, Tanay Jaipuria's seven-source exposition, and the embodied-manipulation survey.">
  Three published robot-data pyramid views, simplified.
</object>
<object class="rollout-bridge-figure rollout-bridge-figure--mobile rollout-bridge-pyramids--mobile" data="/assets/img/from-demonstrations-to-rollouts/published-pyramid-views-mobile.svg" type="image/svg+xml" role="img" aria-label="Mobile comparison of three simplified published robot-data pyramids.">
  Mobile comparison of published robot-data pyramid views.
</object>

_Left: adapted from NVIDIA et al., “GR00T N1,” Figure 1, arXiv:2503.14734v2
(2025), licensed [CC BY 4.0][cc-by]. Right: adapted from Yifan Ye et al., “Data
Pyramid for Embodied Manipulation,” Figure 1, arXiv:2607.24744v2 (2026),
licensed [CC BY 4.0][cc-by]. Both are simplified redraws; changes are ours. The
center is an independently designed schematic based on categories in [Tanay
Jaipuria's article][data-pyramid]; its original image is not embedded or
rehosted._

The word *fidelity* carries several meanings. A compact descriptor is:

$$
D=(D_A,D_B,D_W,C).
$$

Here $D$ is a qualitative record for a declared target policy, deployment
setting, and intended use—not a distance vector or a universal score:

- $D_A$ records the **action-grounding burden**: inference, retargeting, or
  control translation to the target action interface.
- $D_B$ records rough **actor mismatch**: target policy, human, then
  script/planner.
- $D_W$ records rough **world mismatch**: target real, other real, then
  simulated. Relevant details include sensing, latency, contacts, dynamics,
  tasks, resets, stopping rules, and outcome semantics.
- $C$ records the **cost profile**. Fixed setup and validation costs must be
  separated from the marginal human, robot, compute, and curation burden of one
  accepted, auditable episode.

These are qualitative ordinal bands, not measured distances. The same target
policy can act in simulation and reality while visiting different states
because the two worlds return different observations and consequences.

<object class="rollout-bridge-figure rollout-bridge-figure--desktop rollout-bridge-profile--desktop" data="/assets/img/from-demonstrations-to-rollouts/source-profile-matrix.svg" type="image/svg+xml" role="img" aria-label="Comparison matrix for eight robot-data sources. Darker blue means more action-grounding or collection burden; darker green-teal cells mean greater actor or world mismatch to the target.">
  Comparison matrix for common robot-data sources.
</object>
<object class="rollout-bridge-figure rollout-bridge-figure--mobile rollout-bridge-profile--mobile" data="/assets/img/from-demonstrations-to-rollouts/source-profile-matrix-mobile.svg" type="image/svg+xml" role="img" aria-label="Mobile comparison matrix for eight robot-data sources across action grounding, actor, world relation, and collection burden.">
  Mobile comparison matrix for common robot-data sources.
</object>

_Read the shading within a column. In $D_A$ and $C$, darker means more
action-grounding or collection burden. In $D_B$ and $D_W$, darker means farther
from the target under the rough default order. The four fields must never be
added into a scalar ranking._

A strong task-matched planner can be closer than a weak or mismatched human,
and behaviorally exact target-policy data need not be the best teacher when
that policy is still incompetent. Likewise, a high-fidelity target-matched
simulator can be closer than real data from the wrong robot, task, sensors,
resets, or evaluator.

An **Exact\*** action cell means the saved command is logged at the frozen
target action boundary—the representation the learned policy will later emit.
The teleoperation device is then irrelevant; recorded motion alone is exact
only when motion is itself that action. Internet video usually omits commands,
egocentric video requires inference or retargeting, and UMI-style capture still
requires controller mapping. **Target real\*** means the declared task,
setting, embodiment, sensors, resets, and evaluator match; otherwise it is
another real context. **Low\*** means low marginal collection burden, not free
setup, compute, validation, or curation.

<object class="rollout-bridge-figure rollout-bridge-figure--desktop rollout-bridge-map--desktop" data="/assets/img/from-demonstrations-to-rollouts/map-not-a-ladder.svg" type="image/svg+xml" role="img" aria-label="A categorical map separates expert from target-policy behavior and real from simulated worlds without ranking data quality.">
  A map of robot data by actor and world substrate, not a quality ladder.
</object>
<object class="rollout-bridge-figure rollout-bridge-figure--mobile rollout-bridge-map--mobile" data="/assets/img/from-demonstrations-to-rollouts/map-not-a-ladder-mobile.svg" type="image/svg+xml" role="img" aria-label="A mobile categorical map of expert and target-policy data in real and simulated worlds, explicitly not a quality ranking.">
  Mobile actor-and-substrate map of robot data.
</object>

_This is a categorical map, not a score. Position and spacing are not measured
distances, and the highlighted cell is the focus of this article—not a claim
that it is universally best. Related prior framing includes [Varun Nair's “The
Robotics Data Map”][robotics-data-map]; this diagram is an original synthesis,
not a reproduction of that image. The figure shows actor category and world
substrate, not the full $D$ descriptor; “real world” does not automatically
mean that $D_W$ is matched to the intended deployment._

Simulation can expose poses, contacts, forces, masks, and labels. That is
**privileged observability**, not proof that its transitions match deployment.
Usefulness remains target- and role-specific.

## 2. What Ego → UMI → Teleop really reduces

One appealing arrow in the data-map discussion is:

> Ego video → UMI-style capture → robot teleoperation

Read narrowly, this arrow captures a real trend: it often reduces the burden of
turning observed human behavior into commands a robot can execute. It should
not be read as a universal ranking of data quality.

**Egocentric video** can contain objects, affordances, task order, and human
intent, but ordinary recordings do not directly contain target-robot commands.
A system must infer intent, map hands to an end effector, choose a feasible
grasp, and adapt to a different body and controller. [EgoMimic][egomimic]
recovers more action-relevant structure through tracked hand motion and explicit
human–robot alignment; mapping into the target embodiment and action semantics
still remains.

The [Universal Manipulation Interface (UMI)][umi] tracks end-effector pose and
gripper width with a handheld gripper and uses relative trajectories in its
policy interface. This lowers grounding burden but leaves reachability,
inverse-kinematics, collision, controller, and timing mismatches.

**Real target-robot teleoperation** exercises its embodiment and much of its
control stack, reducing retargeting further. Yet a demonstrator and VLA may still
use different action languages, with solvers, low-level controllers, temporal
aggregation, safety filters, or latency handling between policy output and
motors.

The safe conclusion is therefore modest:

> Ego → UMI → Teleop often means less action-grounding and retargeting burden.
> It does not prove that every teleoperation dataset is more useful than every
> UMI or egocentric dataset for every learning objective.

Action grounding is only one axis. It says nothing yet about who induced the
states that appear in the data.

## 3. Who generated the states?

Suppose the policy we plan to deploy is $\pi_\theta$. A demonstration may be
generated by a human, teleoperator, scripted controller, planner, transformed
seed trajectory, or task-specific RL expert. Call that source behavior
$\pi_E$.

The demonstration contains states favored by the source behavior. Autonomous
execution contains states produced by the target policy's own earlier choices.
In general,

$$
d_{\pi_E} \ne d_{\pi_\theta}.
$$

This is the sequential distribution-shift problem emphasized by
[DAgger][dagger]: prediction errors do not merely add one bad label. An early
action changes the next observation, which changes the next action, which can
move the policy farther away from the states represented in expert data.

Imagine a grasp that lands a few millimeters off center. The object rotates,
partly slips, occludes the camera, and presents a view a careful demonstrator
rarely created. The target policy now has to act in a state that arose from its
own mistake. A dataset of flawless demonstrations can be large and still say
little about that recovery.

The two state supports need not have a simple containment relation. The target
policy may visit failure states absent from expert data, while the expert may
visit precise successful states the target never reaches. The important point
is incomplete overlap, not that one support must strictly contain the other.

Here, **target-policy rollout** means a trajectory in which the current target
policy chooses the actions and receives the consequences in closed loop. The
word *rollout* by itself is insufficient. A task-specific RL expert can be
rolled out for millions of episodes and then distilled into a VLA; relative to
that VLA, the episodes are still expert demonstrations because another policy
induced their states.

The four quadrants are worth keeping separate:

- **Real expert data** offers physical embodiment evidence, but an expert—not
  the learned target—selects the states.
- **Simulated expert data** offers breadth, privileged labels, and controlled
  variation, while retaining expert-distribution and simulator gaps.
- **Real target-policy data** most directly shows what the current system does,
  but is costly, risky, and hard to repeat.
- **Simulated target-policy data** matches the actor and enables repeatable
  perturbations; its world and feedback-loop relevance still require evidence.

Crossing one boundary does not erase the other: target-policy simulation is not
reality, and real teleoperation does not reproduce an autonomous policy's state
distribution. Synthetic data is not automatically on-policy, nor real data
automatically generated by the deployed policy. Always ask: **which policy
chose the action that produced the next state?**

## 4. Synthetic demonstrations are still demonstrations

Simulation-based expert factories are valuable because they can create broad,
executable training data without teleoperating every episode. [MimicGen][mimicgen]
transforms object-centric segments from seed demonstrations, executes them in
simulation, and retains successful trajectories. Systems such as
[InternData-A1][interndata-a1] and its public [InternDataEngine][interndataengine]
use task programs, scripted or planned skills, privileged state, compositional
generation, and simulation checks to produce large robot datasets.

These systems can teach task structure, contact strategies, action grounding,
and successful long-horizon behavior. Calling them demonstrations is not a
criticism. A weak target policy needs examples of competence before its own
failures become useful.

But the generator remains external to the target policy. Filtering can also
favor clean successes and remove precisely the awkward states that the target
later creates. More synthetic demonstrations therefore do not answer the same
question as running the target policy itself.

The distinction can be stated simply:

| Expert or exogenous data | Target-policy rollout data |
| --- | --- |
| Shows behavior the learner should imitate or build upon | Shows behavior the current learner actually produces |
| Samples states selected by a demonstrator, script, planner, or teacher | Samples states induced by the target policy's closed-loop choices |
| Often emphasizes competent or filtered execution | Can expose policy-specific failures, hesitation, and recovery attempts |
| Best suited to bootstrapping and broadening competence | Best suited to evaluation, failure mining, correction, and iteration |
{: .rollout-comparison-table .rollout-a11y-table aria-label="Expert and target-policy data compared" }

Neither column wins universally; they answer stage-dependent questions.

## 5. Target-policy rollouts are different—and still not reality

Once a target policy exists, simulation can be used as a controllable
closed-loop environment for that policy. The policy sees an observation,
chooses an action, receives the simulated consequence, and acts again. This can
expose policy-specific failures and recoveries, although what appears still
depends on the task distribution, filters, and the policy itself.

The attraction is practical. After the environment and evaluation stack are
built, simulation can repeat initial conditions, perturb objects and sensors,
and explore far more episodes with low **marginal physical-robot cost**. It
does not make engineering, compute, asset creation, or validation free.

On-policy does not mean representative. Easy resets can hide boundary cases;
pathological perturbations can exaggerate their deployment frequency. The
evidence contract must therefore declare initial-state sampling, task weights,
stopping rules, and whether a run measures ordinary operation or stress tests.

“Run the same policy in sim and real” also needs a strict meaning. The fixed
object should include the serialized checkpoint plus the preprocessing,
prompting, decoder, history, action wrapper, controller interface, timing, and
runtime settings that can change executed behavior. Keeping that contract
fixed does **not** mean the realized actions or trajectories will stay equal.

| Hold fixed or explicitly bind | Allow the experiment to reveal |
| --- | --- |
| Checkpoint and weights | Different observations |
| Image/proprioception preprocessing and history | Different policy outputs caused by those observations |
| Prompt and decoding settings | Different contacts and world responses |
| Action coordinates, normalization, and wrapper | Different failure and recovery trajectories |
| Controller interface, timing, and termination rules | Different task outcomes |
{: .rollout-comparison-table .rollout-a11y-table aria-label="Frozen policy contract and observable consequences" }

Small wrappers can change the evaluated system: crops, camera order, action
decoding, control rate, gripper thresholds, and chunk execution all affect
behavior. A checkpoint is therefore necessary but insufficient; its
policy-facing contract must also be serialized or uniquely reproducible.

The two domain recursions can diverge:

$$
o_t^d=O^d(s_t^d),
\qquad
a_t^d=\pi_\theta(o_t^d),
\qquad
s_{t+1}^d \sim P^d(\cdot \mid s_t^d,a_t^d),
\quad d\in\{S,R\}.
$$

<object class="rollout-bridge-figure rollout-bridge-figure--desktop rollout-bridge-loop--desktop" data="/assets/img/from-demonstrations-to-rollouts/closed-loop-divergence.svg" type="image/svg+xml" role="img" aria-label="One frozen policy identity branches into simulated and real feedback loops whose observations, actions, and next states can diverge.">
  One policy contract entering different real and simulated closed loops.
</object>
<object class="rollout-bridge-figure rollout-bridge-figure--mobile rollout-bridge-loop--mobile" data="/assets/img/from-demonstrations-to-rollouts/closed-loop-divergence-mobile.svg" type="image/svg+xml" role="img" aria-label="A mobile diagram showing one frozen policy contract entering different real and simulated closed loops.">
  Mobile real-versus-simulated closed-loop diagram.
</object>

_The checkpoint can remain fixed while the closed-loop trajectories separate.
“Same policy” is an identity and runtime contract, not a promise of equal
actions._

This is why a simulated target-policy rollout is not “distance zero” from
deployment. It may eliminate one kind of mismatch—the identity of the acting
policy—while retaining gaps in cameras, latency, controllers, contacts,
dynamics, reset distributions, and success semantics.

Paired teleoperation can reveal camera, kinematic, timing, contact, and
system-identification gaps. It is a useful lower-level diagnostic, not a
universal prerequisite or proof of target-policy transfer: a competent operator
may avoid the collisions, occlusions, and recoveries that distinguish policy
behavior across worlds.

Rollout curation must not erase the phenomenon of interest. Success-only
filtering hides failures; unlabeled broken episodes mix policy errors with
simulator crashes or invalid observations. Useful records keep planned and
executed attempts, outcomes, and system failures distinct.

Ordinary rollouts estimate a declared operating distribution; targeted
perturbations probe weak regions. Labeling those lanes prevents a stress-test
failure from becoming a claimed deployment rate, or an average from hiding a
repeatable failure. Simulation eases both without making them the same claim.

[SIMPLER][simpler] and [REALM][realm] study paired sim/real policy evaluation
under aligned protocols: visual plausibility is insufficient; behavior and
outcomes must be compared. Even then, evidence remains tied to the tested
policies, tasks, evaluator, and use.

## 6. Different data are useful at different stages

An untrained policy can generate unlimited on-policy data by moving randomly.
That data perfectly matches its current behavior and may still teach almost
nothing about completing the task. Early imitation learning often needs
competent examples. Later, another batch of nearly identical expert successes
may be less valuable than a smaller set of failures near the policy's competence
boundary.

<img class="rollout-bridge-figure rollout-bridge-learning-stage"
  src="/assets/img/from-demonstrations-to-rollouts/learning-stages.webp"
  alt="A novice robot follows clear successes; a competent robot later faces redundant easy wins and diverse near-failures."
  decoding="async">

_Conceptual illustration: usefulness changes with learning stage; this is not a
universal ranking._

This suggests a lifecycle rather than a winner. Broad visual and language data
can establish priors. Demonstrations connect those priors to a robot and a
task. Once the target policy becomes competent, autonomous rollouts reveal its
own boundary cases. Human interventions, corrected demonstrations, or
synthetic expert generation can turn those cases back into training material.
The updated policy must then be evaluated again because its state distribution
has changed.

The $D$ descriptor organizes mismatches and collection burden; it does not by
itself measure training value. To retain the useful scale argument without
inventing a quantitative law, let $\mathcal X$ denote a dataset and $\mathcal J$
a declared learning or engineering job:

$$
\begin{aligned}
V_{\mathcal J}(\mathcal X)
  &=F_{\mathcal J}(N,I,Q,M,\ldots),
  \qquad F_{\mathcal J}\ \text{unspecified},\\
N_{\mathrm{raw}}\uparrow
  &\not\Rightarrow V_{\mathcal J}(\mathcal X)\uparrow.
\end{aligned}
$$

| Term | Question it represents |
| --- | --- |
| $N$ | How much effective coverage does the dataset provide, rather than merely how many rows were written? |
| $I$ | How much incremental information does another sample add for the current corpus and learner? |
| $Q$ | How reliable are the observations, actions, outcomes, failure records, and use-relevant dynamics? |
| $M$ | How well does the data match the target task, actor, state distribution, and learning objective? |
{: .rollout-value-factor-table .rollout-a11y-table .rollout-row-header-table aria-label="Factors that may influence job-specific data value" }

This is a checklist, not an estimator. The factors are not assumed independent,
monotone, sufficient, or calibrated onto a common scale. Simulation can make
raw $N$ enormous, while repetitive coverage may add little $I$, unreliable
records or consequential simulator error may reduce $Q$, and the wrong actor
or task distribution may reduce $M$. The memorable “a billion times nearly
nothing is still nearly nothing” slogan points at that bottleneck; the
defensible claim is the weaker one displayed above. Only matched retraining and
frozen real evaluation can establish positive training value for a particular
use.

There is another boundary worth making explicit. Suppose a simulator preserves
enough policy behavior to help choose which checkpoint deserves real testing.
That does not establish that training on its failure trajectories will improve
the real robot:

$$
\text{valid for policy evaluation}
\;\not\Rightarrow\;
\text{valid as policy-training data}.
$$

The training claim needs a stronger experiment: mine or generate simulated
data, update the policy, and then measure the effect in reality. Evaluation and
training can share infrastructure, but they are different claims.

The resulting picture is less dramatic than “rollouts replace
demonstrations,” and more useful:

> Demonstrations bootstrap competence. Target-policy rollouts reveal what
> remains wrong. Simulation can scale both, subject to different validation
> burdens.

## 7. When simulated rollouts inform a decision

A simulator can be a behavior-data engine, an environment for target-policy
rollouts, or a tool in a bounded policy decision. These roles are related, but
evidence for one does not automatically validate the others.

Once a simulator is used as a closed-loop environment for a specific policy, a
harder question appears: what are we allowed to conclude from those rollouts?

If five frozen policy candidates are available but real-robot budget is
limited, a simulator might be asked to choose one candidate, reject a pairwise
difference as unresolved, or abstain. The operational question is not simply
whether two leaderboards have a high correlation. It is whether a decision
rule, using simulation evidence only, issues a particular action—and what
happens to that unchanged action when evaluated against protected real
evidence.

That is a much narrower use than declaring a simulator “realistic” or “valid.”
It binds the claim to an exact finite policy set, task set, evaluator, policy
identity contract, and decision. Correlation and rank agreement remain useful
diagnostics, but they do not replace an audit of the choice the simulator was
actually allowed to make, including abstention.

The sim-to-real gap matters because it can destroy the information we hoped to
obtain from target-policy rollouts. The right validation question therefore
depends on the action those rollouts are supposed to support.

Simulation is not one point on a data pyramid. It can multiply demonstrations,
generate expert data, host policies, and—after validation—support bounded
decisions. Separating these roles clarifies the promise and evidence burden.

## Notation at a glance

| Symbol | Meaning |
| --- | --- |
| $D=(D_A,D_B,D_W,C)$ | Qualitative profile: action-grounding burden, rough actor mismatch, rough world mismatch, and cost. |
| $\pi_\theta$, $\pi_E$; $d_\pi$ | Target and external policies; the state distribution induced by policy $\pi$. |
| $S$, $R$; $o_t,a_t,s_t$ | Simulation or reality superscripts; observation, action, and state at time $t$. |
| $O$, $P$, $\tau$ | Observation map, world transition or dynamics, and trajectory. |
| $\mathcal X$, $\mathcal J$; $V_{\mathcal J}(\mathcal X)$, $F_{\mathcal J}$ | Dataset, declared job, job-specific value, and its unspecified dependency. |
| $N_{\mathrm{raw}}$; $N,I,Q,M$ | Raw count; effective coverage, incremental information, reliability, and target match. |
{: .rollout-notation-table .rollout-a11y-table .rollout-row-header-table aria-label="Mathematical notation used in this article" }

## References and further reading

- [From Demos to Simulation Engines: How Robot Data Generation Is Becoming a Sim Stack][simulation-data-engines]
- [NVIDIA GR00T N1 and its three-layer data pyramid][groot-data]
- [Tanay Jaipuria: The Data Pyramid in Robotics][data-pyramid]
- [Data Pyramid for Embodied Manipulation: A Survey][embodied-pyramid]
- [Varun Nair: Robotics Data Map][robotics-data-map]
- [EgoMimic][egomimic]
- [Ross, Gordon, and Bagnell: DAgger][dagger]
- [Chi et al.: Universal Manipulation Interface][umi]
- [Mandlekar et al.: MimicGen][mimicgen]
- [Tian et al.: InternData-A1][interndata-a1]
- [InternDataEngine repository][interndataengine]
- [Li et al.: SIMPLER][simpler]
- [Sedlacek et al.: REALM][realm]

[simulation-data-engines]: /posts/robot-data-generation-simulation-stack/
[groot-data]: https://arxiv.org/abs/2503.14734
[data-pyramid]: https://www.tanayj.com/p/the-robot-data-pyramid
[embodied-pyramid]: https://arxiv.org/abs/2607.24744
[robotics-data-map]: https://x.com/_varunnair/status/2090126022465495083
[egomimic]: https://arxiv.org/abs/2410.24221
[dagger]: https://proceedings.mlr.press/v15/ross11a.html
[umi]: https://arxiv.org/abs/2402.10329
[mimicgen]: https://proceedings.mlr.press/v229/mandlekar23a.html
[interndata-a1]: https://openaccess.thecvf.com/content/CVPR2026/html/Tian_InternData-A1_Pioneering_High-Fidelity_Synthetic_Data_for_Pre-training_Generalist_Policy_CVPR_2026_paper.html
[interndataengine]: https://github.com/InternRobotics/InternDataEngine
[simpler]: https://proceedings.mlr.press/v270/li25c.html
[realm]: https://arxiv.org/abs/2512.19562
[cc-by]: https://creativecommons.org/licenses/by/4.0/
