@reexport module BranchMDP

export BranchMDPEnv

using ReinforcementLearningBase

mutable struct BranchMDPEnv <: AbstractEnv
    transition::Array{Int,3}
    rewards::Array{Float64,3}
    current::Int
    termination_prob::Float64
    reward::Float64
    observation_space::DiscreteSpace
    action_space::DiscreteSpace

    BranchMDPEnv(ns::Int, na::Int, b::Int, termination_prob::Float64 = 0.1) =
        new(
            rand(1:ns, ns, na, b),
            randn(ns, na, b),
            1,
            termination_prob,
            0.0,
            DiscreteSpace(ns + 1),
            DiscreteSpace(na),
        )
end

RLBase.get_observation_space(env::BranchMDPEnv) = env.observation_space
RLBase.get_action_space(env::BranchMDPEnv) = env.action_space

function (env::BranchMDPEnv)(a::Int)
    if rand() < env.termination_prob
        env.reward = 0.0
        env.current = size(env.transition, 1) + 1
    else
        b = rand(1:size(env.transition, 3))
        s′ = env.transition[env.current, a, b]
        r = env.rewards[env.current, a, b]
        env.current = s′
        env.reward = r
    end
    nothing
end

RLBase.observe(env::BranchMDPEnv) =
    (
        reward = env.reward,
        terminal = env.current == size(env.transition, 1) + 1,
        state = env.current,
    )

function RLBase.reset!(env::BranchMDPEnv, s::Int = 1)
    env.current = s
    nothing
end

end