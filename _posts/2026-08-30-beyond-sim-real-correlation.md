---
title: "Can Simulation Tell Us Which Robot Policy Will Work in Reality?"
date: 2026-08-30 22:30:00 +0800
categories: [Robotics, Simulation]
tags: [robotics, simulation, vla, evaluation, sim-to-real, policy-selection, genesis-world]
math: true
toc: true
description: "Beyond sim–real correlation: test which policy simulation chooses, when it abstains, and what that choice costs in reality."
---

In May 2026, Genesis AI argued that robotics should treat simulation as an
**evaluation and iteration engine**, not merely as a factory for synthetic
training data. Its official report says that
a real evaluation pass spanning hundreds of tasks and repeated episodes would
consume more than 200 continuous robot-hours, while the corresponding tens of
thousands of simulated episodes run in under half an hour and reproduce
bit-exactly. Once evaluation becomes that cheap, every checkpoint, branch, and
hyperparameter change can be scored continuously in the
[reported setup][genesis-world].

This raises the next question:

> **If simulation becomes the scoring layer of robot-policy development, when
> should its scores decide which policy receives scarce real-robot time?**

Imagine five exact vision-language-action policies—call them A through E—and
enough sustained real-robot development budget to seriously pursue only one.
Simulation can score all five across four fixed manipulation tasks. Which
policy gets the robot time? When should the simulator refuse to choose? How
much real opportunity is lost when it chooses badly?

*The numerical examples use one constructed five-policy, four-task dataset to
make the decision quantities concrete.*

A simulation-only rule chooses a policy—or abstains. Held-out real results then
tell us what that choice cost. We study this at two scales:

- a **global lane** that chooses one policy from the complete finite candidate
  set—or abstains; and
- a **pairwise lane** that explains where local simulated preferences were
  strict successes, harmless near-ties, harmful reversals, or abstentions.

Use the pairwise results to explain local errors. Do not tally them to choose
the global winner.

<style>
  .selector-audit-figure { display: block; width: 100%; border: 0; }
  .selector-audit-figure--mobile { display: none; }
  .selector-audit-two-loop--desktop { aspect-ratio: 1200 / 780; }
  .selector-audit-two-loop--mobile { aspect-ratio: 720 / 1500; }
  .table-wrapper > table.selector-audit-table {
    width: 100% !important;
    min-width: 0 !important;
    table-layout: fixed;
  }
  .table-wrapper > table.selector-audit-table :is(th, td) {
    white-space: normal !important;
    vertical-align: top;
    overflow-wrap: anywhere;
  }
  @media screen and (max-width: 575px) {
    .selector-audit-figure--desktop { display: none; }
    .selector-audit-figure--mobile { display: block; }
  }
  @media print {
    .selector-audit-figure--desktop { display: block; }
    .selector-audit-figure--mobile { display: none; }
  }
</style>

## 1. Simulation is becoming the scoring layer

A simulator can be a data source, a measurement instrument, or an optimization
environment. Those roles are related, but they are not interchangeable.

| Role | Question |
|---|---|
| Data source | What simulated experience should train the policy? |
| Measurement instrument | Which candidate policy should receive real resources? |
| Optimization environment | What happens when policies and research decisions adapt to the simulator itself? |
{: .selector-audit-table }

[Genesis World 1.0][genesis-world]
emphasizes the middle role. Its team reports evaluating three
models across fourteen tasks, with 200 episodes per task, and obtaining Pearson
correlation $0.8996$ and Mean Maximum Rank Violation (MMRV) $0.0166$ between
simulation and hardware in its reported setup. The team also wants simulation
to become cheap enough that checkpoints, research branches, and eventually
post-training loops can be evaluated continuously.

When evaluation falls from hundreds of robot-hours to a fraction of an hour of
compute, simulation can become the objective against which an entire research
program iterates.

A physical benchmark limits how often a team can repeat a mistaken choice. A
cheap simulator can make and reinforce that choice at every checkpoint.

Here we treat simulation as a **measurement instrument** and ask when its
ranking should decide which policy receives real robot time.

## 2. Five exact policies, one real commitment

We ask the simulator to do one narrow job:

> **Choose from a fixed finite candidate set for one deployment setting—or
> abstain.**

Each candidate is a **specific executable policy** tested under the same task
and simulator setup. More rollouts can sharpen the answer for these policies;
they do not extend it automatically to future checkpoints, robots, or
simulators.

The question is not whether the simulator is “valid” in general. It is whether
we can trust it for this particular choice. Validation standards call this the
simulator's *context of use*. See [NASA-STD-7009B][nasa-7009b] for the general
principle.

Write the simulation choice as

$$
a_S(D_S)
\in
\{P_1,\ldots,P_K,\bot\},
$$

where $D_S$ contains the simulation results and $\bot$ means abstention. What
we care about is the choice, not the ranking by itself.

## 3. Closed-loop simulation still leaves one loop open

Robotics rightly distinguishes closed-loop rollout from open-loop action
prediction.

The first loop is the **policy–environment loop**:

$$
\text{observation}
\rightarrow
\text{policy}
\rightarrow
\text{action}
\rightarrow
\text{world}
\rightarrow
\text{next observation}.
$$

A closed-loop simulator can expose compounding errors in perception, contact,
control, and recovery that a static action-prediction metric misses.
[Genesis's side-by-side real/sim rig][genesis-world] is designed to localize
divergence across rendering, physics, communication, and low-level control.

Policy development contains a second loop—the **research-decision loop**:

$$
\{P_1,\ldots,P_K\}
\rightarrow
\text{simulation evidence}
\rightarrow
\text{choose / reject / abstain}
\rightarrow
\text{real consequence}.
$$

A simulator can close the first loop without testing whether its scores lead
to good research choices. It can produce plausible trajectories and still:

- select the wrong checkpoint;
- choose even when finite rollout data do not distinguish two policies;
- preserve rankings on visual perturbations but fail on contact-heavy tasks;
- choose the relative best when every candidate is absolutely unacceptable; or
- become increasingly exploitable as researchers optimize against its errors.

> **Closed-loop rollout shows what a policy does inside the simulator. It does
> not tell us whether to trust the policy choice made from those rollouts.**

<object class="selector-audit-figure selector-audit-figure--desktop selector-audit-two-loop--desktop" data="/assets/img/beyond-sim-real-correlation/policy-loop-vs-research-decision-loop.svg" type="image/svg+xml" role="img" aria-label="A policy-environment feedback loop is separate from the research-decision loop that records a simulation choice before checking it against held-out real results.">
  Two separate loops: simulated policy feedback and held-out testing of the research choice.
</object>
<object class="selector-audit-figure selector-audit-figure--mobile selector-audit-two-loop--mobile" data="/assets/img/beyond-sim-real-correlation/policy-loop-vs-research-decision-loop-mobile.svg" type="image/svg+xml" role="img" aria-label="Mobile diagram separating the simulated policy loop from the research-decision loop and its held-out real test.">
  Mobile view of the policy and research-decision loops.
</object>

_Closed-loop rollout can expose compounding behavior without yet justifying the
policy choice. The second loop records the choice before checking it against
held-out real results._

## 4. Pearson, MMRV, and the choice simulation actually made

A sim–real scatter plot is useful. So are two leaderboards.

Pearson correlation asks whether simulated and real scores have a strong linear
association. Spearman and Kendall ask whether their ordinal structure is
similar. Top-$k$ overlap focuses attention near the front of the ranking.

But none, by itself, tells us:

- which policy the finite-data rule chose;
- whether it was allowed to abstain;
- which differences were practically important;
- how the intended task mix weighted each policy-task result; or
- what the global choice cost in reality.

> **Example.** Across the 20 policy-task cells, Pearson association is $0.838$
> and Spearman association is $0.806$. Yet the simulation rule selects policy A
> while policy B has the highest real finite-set utility.

### MMRV gets closer to the decision problem

[SIMPLER][simpler] introduced Mean Maximum Rank Violation to penalize a reversed
pair by the real performance gap attached to that reversal. In the source
notation, $R_i$ and $R_{S,i}$ are real and simulated policy scores, and $N$ is
the number of policies. For policies $i$ and $j$,

$$
\operatorname{RankViolation}(i,j)
=
|R_i-R_j|
\mathbf 1\!\left[
(R_{S,i}<R_{S,j})\ne(R_i<R_j)
\right],
$$

and

$$
\operatorname{MMRV}
=
\frac{1}{N}
\sum_{i=1}^{N}
\max_j \operatorname{RankViolation}(i,j).
$$

That is closer to the decision we care about: reversing two nearly tied
policies matters less than reversing policies separated by a large real gap.
But an MMRV value still does not tell us:

- what simulation chose after finite-data uncertainty was considered;
- whether the selector declined to act;
- what task weights defined the deployment target;
- whether the selected policy cleared an absolute utility or safety floor; or
- what opportunity loss belongs to the one policy actually selected from the
  complete set.

These metrics answer different questions:

| Layer | Question answered |
|---|---|
| Pearson / rank correlation | Do score patterns move together? |
| MMRV | How severe are the real gaps attached to ranking inversions? |
| Choice test | What did the rule choose, how often did it abstain, and what did that choice cost in reality? |
{: .selector-audit-table }

> Report association and MMRV, then separately report what the selection rule
> did and what it cost.

[Ma and Zhao's selection-aware surrogate study][ma-zhao] describes the same
general phenomenon outside robotics: once a proxy is used to choose the winner,
errors near that winner matter much more than average predictive fit. Robot
policy selection gives that general problem a concrete form.

<details markdown="1">
<summary>Technical sidebar: how MMRV relates to opportunity loss</summary>

There is a neat connection here. Look at the MMRV row of the policy simulation
actually chose: its largest violation is exactly the real opportunity loss of
that choice.

On one higher-is-better scalar score, let $\hat i$ be the policy selected by
simulation, with ties resolved by the declared rule. Because no policy has a
higher simulated score than $\hat i$,

$$
\operatorname{RankViolation}(\hat i,j)
=
(R_j-R_{\hat i})_+.
$$

Call the selected row's largest violation

$$
\operatorname{SRV}(\hat i)
:=
\max_j \operatorname{RankViolation}(\hat i,j).
$$

Since $G:=\max_j R_j-R_{\hat i}$, the opportunity loss of the simulation choice
is exactly its selected-row violation:

$$
\boxed{
G
=
\operatorname{SRV}(\hat i)
\le
N\,\operatorname{MMRV}
}
$$

MMRV is therefore close to opportunity loss, but it does not itself choose a
policy, abstain under uncertainty, or test an absolute floor.

</details>

## 5. Calibrate with reality, then hold out a real test

Use real data freely to calibrate cameras, contact, timing, assets, controllers,
and score functions. Then set aside fresh real trials. Let
$D_{\mathrm{dev}}$ be the development data, $D_S$ the simulation evaluation,
and $D_R$ the held-out real evaluation:

$$
D_{\mathrm{dev}}
\longrightarrow
\text{fix simulator and rule}
\longrightarrow
D_S
\longrightarrow
\text{choose}
\longrightarrow
D_R.
$$

Real-blind does not mean reality-free. Genesis's side-by-side rig fits naturally
in $D_{\mathrm{dev}}$: use real data to locate mismatches and improve the
simulator, then use different real trials in $D_R$ to test the choice. Training
the policy only on real data also reduces one route for exploiting simulator
quirks, but it does not replace the held-out test.

## 6. Check the global choice first

The opening asks a global question: which one of the five policies receives the
robot time? Start there.

Let nonnegative task weights $\nu_t$ sum to one. For policy $i$ in domain
$d\in\{S,R\}$, define

$$
U_i^d
=
\sum_t
\nu_t u_t(\theta^d_{i,t}),
$$

Here $\theta^d_{i,t}$ is task performance and $u_t$ maps it to the value of that
task. If simulation chooses $a_S$, the held-out real results answer four
different questions.

### 1. Did it choose an exact real best? — PCS

The **posterior probability of correct selection (PCS)** allows ties among the
real best policies:

$$
\operatorname{PCS}_{\mathrm{post}}
=
P\!\left(
a_S\in\arg\max_i U_i^R
\mid D_R
\right).
$$

### 2. Did it choose something practically good enough? — PGS

For an inclusive utility tolerance $\epsilon_U\ge0$, the **posterior probability
of good selection (PGS)** asks whether the chosen policy is close enough to the
real best:

$$
\operatorname{PGS}_{\mathrm{post}}(\epsilon_U)
=
P\!\left(
\max_i U_i^R-U_{a_S}^R\le\epsilon_U
\mid D_R
\right).
$$

### 3. Was the selected policy absolutely acceptable?

Every candidate might be bad, so relative rank also needs an absolute floor:

$$
U_{a_S}^R\ge U_{\min}.
$$

### 4. What real opportunity was lost?

For a non-abstaining action, the real opportunity loss—or simple regret—is

$$
G
=
\max_i U_i^R-U_{a_S}^R
\ge0.
$$

These quantities are not interchangeable. A policy can be close to the best
yet fall below the absolute floor. It can have low exact-best
probability but tiny opportunity loss because the leaders are nearly tied.
High PGS does not show that any candidate is useful.

> **Example.** The global rule selects A. B is the exact real
> best; B, C, and D lie in the inclusive $0.03$ good-selection set. A is outside
> that set but remains above the absolute floor. Its real
> opportunity loss is $0.0375$.

These are standard ranking-and-selection quantities. See
[Eckman and Henderson][eckman-henderson] for fixed-tolerance good selection and
[Chick and Inoue][chick-inoue] for expected opportunity cost.

If reality evaluates only the policy simulation selected, the study cannot know
whether an untested candidate was better. Full-set PCS, PGS, and opportunity
loss therefore require real information about the comparison set.

If $a_S=\bot$, do not set regret to zero. The selected-policy quantities are
undefined.

## 7. Use pairwise choices to locate errors

Pairwise results show where the evaluator was confident, indecisive,
harmlessly wrong, or harmfully wrong.

For each policy pair $(i,j)$ and task $t$, let the simulation-only choice be

$$
A^S_{ij,t}(D_S)
\in
\{-1,0,+1\},
$$

where $+1$ chooses policy $i$, $-1$ chooses policy $j$, and $0$ abstains.

Finite rollouts make small score gaps uncertain. A rule forced to choose every
time turns uncertainty into a direction. Abstention means only that the rule
did not choose either policy; it does **not** prove that they are equivalent.

Three thresholds answer three distinct questions. Set them before looking at
the held-out real results.

| Quantity | Question |
|---|---|
| Simulator practical gap $m^S_t$ | Is the simulated difference large enough to matter? |
| Evidence threshold $\gamma^S_{ij,t}$ | Does finite $D_S$ support that direction strongly enough to act? |
| Real consequence margin $\epsilon^R_t$ | Was the choice strictly confirmed, merely non-harmful, or harmful in reality? |
{: .selector-audit-table }

Define the latent real gap as
$\Delta^R_{ij,t}=\theta^R_{i,t}-\theta^R_{j,t}$. Once $D_R$ is opened, orient
that gap toward the policy chosen by simulation:

$$
X^R_{ij,t}
=
A^S_{ij,t}\Delta^R_{ij,t}.
$$

With real practical margin $\epsilon^R_t\ge0$, every pair-task choice falls
into exactly one of four groups:

1. **Abstention:** $A^S_{ij,t}=0$.
2. **Strictly correct choice:** $A^S_{ij,t}\ne0$ and
   $X^R_{ij,t}>\epsilon^R_t$.
3. **Within the practical tolerance:** $A^S_{ij,t}\ne0$ and
   $-\epsilon^R_t\le X^R_{ij,t}\le\epsilon^R_t$.
4. **Harmful reversal:** $A^S_{ij,t}\ne0$ and
   $X^R_{ij,t}<-\epsilon^R_t$.

The middle category is not called “correct.” It includes small reversals inside
the practical tolerance. Let $P_\omega$ denote the weighted fraction over
policy pairs and tasks. The four unconditional masses are

$$
\begin{aligned}
M_0 &= P_\omega(A^S=0),\\
M_+ &= P_\omega(A^S\ne0,\ X^R>\epsilon_t^R),\\
M_{\sim} &= P_\omega(A^S\ne0,\ |X^R|\le\epsilon_t^R),\\
M_- &= P_\omega(A^S\ne0,\ X^R<-\epsilon_t^R).
\end{aligned}
$$

Once simulation has made its choices, $M_0$ and coverage are known. The other
three masses must be estimated from finite real trials.

Therefore,

$$
\boxed{M_0+M_++M_{\sim}+M_-=1.}
$$

The fraction of pair-task cases where simulation makes a choice is the
coverage:

$$
C_{\mathrm{op}}=1-M_0.
$$

Only when $C_{\mathrm{op}}>0$ do conditional rates exist:

$$
R_{\mathrm{strict}}=\frac{M_+}{C_{\mathrm{op}}},
\qquad
R_{\mathrm{nonharm}}=\frac{M_++M_{\sim}}{C_{\mathrm{op}}},
\qquad
R_{\mathrm{harm}}=\frac{M_-}{C_{\mathrm{op}}}.
$$

![Four consequence masses with 35 percent coverage and outcome rates among choices.](/assets/img/beyond-sim-real-correlation/four-masses-two-denominators.svg?v=20260830b)
_Illustrative equal-task operating point. The unconditional result and the among-choice rate answer different questions._

> **Example.** Here $M_0=0.650$ and $M_+=0.300$; both
> $M_{\sim}$ and $M_-$ are $0.025$. Coverage is $0.350$. Among choices it made,
> the non-harm rate is about $0.93$ and the harm rate is about $0.07$. Reporting
> “93% were non-harmful” alone would hide that the rule abstained on 65% of the
> pair-task cases.

If the rule abstains everywhere, then
$(M_0,M_+,M_{\sim},M_-)=(1,0,0,0)$ and $C_{\mathrm{op}}=0$. Conditional rates
are undefined, not zero.

Varying the evidence threshold traces the established risk–coverage trade-off
from [selective prediction][el-yaniv-wiener]. Choose the operating point before
looking at the held-out harm rate.

Pair choices can be cyclic: the evaluator may prefer A to B, B to C, and C to
A. They explain local errors; they do not by themselves produce a global
winner.

## 8. Simulator validity depends on the tasks and conditions

Weights are part of the scientific question. Equal-task, family-balanced, and
deployment-weighted analyses ask different things even when the underlying
rollouts are identical.

![The same pair actions and outcomes under equal-task and cable-heavy target weights.](/assets/img/beyond-sim-real-correlation/weighting-changes-the-target.svg?v=20260830b)
_Changing the weights changes the aggregate question while leaving the observations unchanged._

> **Example.** Reweighting unchanged task panels from equal task
> weights to a cable-heavy task mix raises coverage from
> $0.350$ to $0.410$ and unconditional harmful mass from $0.025$ to $0.055$.
> No observation or action changed. The target question changed.

[Genesis World 1.0][genesis-world] structures robustness evaluation along
perturbation axes such as lighting conditions, camera perturbation, object
placement, robot configuration, and language rephrasing. Report a **validity
envelope** across these conditions rather than one simulator-wide number, with
the same quantities reported by task or axis:

$$
M_{0,a},\quad M_{+,a},\quad M_{\sim,a},\quad M_{-,a},\quad G_a.
$$

The result could look like this:

| Axis | Decision-oriented status |
|---|---|
| Lighting and background | high coverage, low harmful-choice mass |
| Camera displacement | moderate coverage, several consequential inversions |
| Contact and friction | not enough held-out real data |
| Semantic paraphrase | ranking preserved, but absolute utility below the chosen floor |
{: .selector-audit-table }

_An illustrative decision-oriented validity envelope._

A deployment-weighted average can summarize this profile, but it should not
hide bad conditions that matter on the robot.

The [Genesis report][genesis-world] also emphasizes bit-exact repeatability.
This makes matched replay and precise comparisons easier. Repeatability is not
accuracy:

> **Determinism removes noise from the instrument; it does not prove that the
> instrument is measuring the right world.**

More seeds or bootstrap iterations improve precision; they do not create new
independent real-world conditions.

## 9. When the measurement instrument becomes an optimization target

Genesis proposes scoring every candidate policy, experimental branch, and
hyperparameter change automatically. Its [roadmap][genesis-world] also
describes a future in which simulation serves as both environment and critic
during post-training.

That changes the statistical problem.

Suppose a simulator score can be written schematically as

$$
S(P)=R(P)+\varepsilon(P),
$$

where $R(P)$ is real utility and $\varepsilon(P)$ is simulator error. If a team
selects

$$
\widehat P
=
\arg\max_{P\in\mathcal C}S(P),
$$

then simulator error matters as well as real utility. If that error varies
across policies, taking the highest simulated score also tends to pick policies
that got lucky in simulation. The larger the search, the more opportunities
there are to get lucky. This is the fixed-pool [**optimizer's
curse**][smith-winkler]. Repeated adaptive reuse adds a separate risk: the
research process can overfit the evaluation evidence itself, as formalized in
[adaptive data analysis][dwork-adaptive].

Making evaluation cheap can also make simulator error something the optimizer
learns to exploit.

There are two cases:

| Context | Question |
|---|---|
| **Evaluator validity** | Can simulation assess independently produced or fixed candidate policies? |
| **Validity under simulator-influenced optimization** | Does predictiveness survive after policies, checkpoints, or research choices adapt to the simulator? |
{: .selector-audit-table }

A simulator tested on a small fixed model set is not automatically ready to
choose among hundreds of searched checkpoints, sim–real co-trained policies,
or policies optimized by RL against that simulator. The [optimizer's
curse][smith-winkler] can grow with the search pool, repeated [holdout
reuse][dwork-adaptive] can overfit the evaluation set, so the earlier validation
no longer automatically applies.

Once simulation starts shaping the candidate policies, the validation question
changes with them. This article stops at the fixed-pool case.

The next question is:

> **What changes when simulation becomes the coach as well as the referee?**

## 10. The decisive experiment—and its limits

Take several specific executable policies and let the simulator choose using
only simulated results. Then test enough of the same candidates in reality to
learn whether its choice was best, close enough, absolutely acceptable, or
costly. Record the simulation choice before looking at those real results.

The constructed example shows how to ask those questions, not how often one
answer occurs in current VLA systems. Genesis gives a strong contemporary
example of simulation as an evaluator. [WMBench][wmbench] goes further and asks
whether generated rollouts preserve real policy outcomes and rankings. Its
[current public release][wmbench-release] is still partial, so we do not yet
have the joined multi-policy result set needed to replay the final step here:
let simulation choose first, then measure the real cost of that choice.

This experiment has three limits:

1. **The conclusion is local.** It concerns these executable policies, tasks,
   evaluator, robot setup, and target weights—not every future VLA.
2. **The global endpoints need the full comparison.** Evaluating only the
   simulator's winner cannot reveal whether an untested candidate was better.
3. **Adaptive optimization changes the question.** Once policies are trained or
   repeatedly selected against the simulator, a fixed-pool validation no longer
   covers the new search process.

Pearson, Spearman, Kendall, top-$k$, MMRV, calibration plots, and perturbation
profiles still belong in the report. Show them alongside what simulation chose
and what that choice cost.

Genesis illustrates how simulation can become cheap enough to score a large
fraction of one robotics R&D loop. Cheap, repeated choices are worth checking
explicitly.

> **When simulation chooses, test that choice against held-out real results.
> Report when it abstains and what the choice costs.**

## References and further reading

- [Genesis AI: The Role of Simulation in Scalable Robotics—Genesis World 1.0 and the Path Forward][genesis-world]
- [NASA-STD-7009B: Standard for Models and Simulations][nasa-7009b]
- [Li et al.: SIMPLER—Evaluating Real-World Robot Manipulation Policies in Simulation][simpler]
- [Eckman and Henderson: Posterior Bounds on the Probability of Good Selection][eckman-henderson]
- [Chick and Inoue: New Two-Stage and Sequential Procedures for Selecting the Best Simulated System][chick-inoue]
- [El-Yaniv and Wiener: On the Foundations of Noise-Free Selective Classification][el-yaniv-wiener]
- [Smith and Winkler: The Optimizer's Curse][smith-winkler]
- [Dwork et al.: Generalization in Adaptive Data Analysis and Holdout Reuse][dwork-adaptive]
- [Ma and Zhao: When May a Model Replace the Experiment?][ma-zhao]
- [GigaWorld-1 / WMBench paper][wmbench]
- [GigaWorld-1 official repository and public-release status][wmbench-release]

[genesis-world]: https://www.genesis.ai/blog/the-role-of-simulation-in-scalable-robotics-genesis-world-10-and-the-path-forward "The Role of Simulation in Scalable Robotics: Genesis World 1.0 and the Path Forward"
[nasa-7009b]: https://standards.nasa.gov/standard/NASA/NASA-STD-7009 "NASA-STD-7009B: Standard for Models and Simulations"
[simpler]: https://arxiv.org/abs/2405.05941v1 "Evaluating Real-World Robot Manipulation Policies in Simulation"
[eckman-henderson]: https://doi.org/10.1145/3432754 "Posterior Bounds on the Probability of Good Selection"
[chick-inoue]: https://doi.org/10.1287/opre.49.5.732.10615 "New Two-Stage and Sequential Procedures for Selecting the Best Simulated System"
[el-yaniv-wiener]: https://jmlr.org/papers/v11/el-yaniv10a.html "On the Foundations of Noise-Free Selective Classification"
[smith-winkler]: https://doi.org/10.1287/mnsc.1050.0451 "The Optimizer's Curse: Skepticism and Postdecision Surprise in Decision Analysis"
[dwork-adaptive]: https://proceedings.neurips.cc/paper/2015/hash/bad5f33780c42f2588878a9d07405083-Abstract.html "Generalization in Adaptive Data Analysis and Holdout Reuse"
[ma-zhao]: https://arxiv.org/abs/2608.01378v1 "When May a Model Replace the Experiment? Audits, Licenses, and the Price of Trust in Surrogate-Driven Design"
[wmbench]: https://arxiv.org/abs/2607.02642 "GigaWorld-1: A Roadmap to Build World Models for Robot Policy Evaluation"
[wmbench-release]: https://github.com/open-gigaai/giga-world-1 "GigaWorld-1 official public repository"
