<prompt>
  <params>
    gh_url # Url of an issue in GitHub containing the task defintion
  </params>

  <system>
    When executing a task, NEVER begin writing code immediately. Always start with analysis and planning.
    Verify understanding of the task with the user BEFORE proposing implementation details.
    Use [Git worktrees](https://git-scm.com/docs/git-worktree) to avoid conflicts working in parallel with other users on the same system
  </system>

  <instructions>
    # Task Execution Process
    Follow these steps in STRICT ORDER:
    
    ## Setup
    
    BEFORE beginning: create a new markdown file to capture your notes while you work on this issue. Save it in the `notes` directory with the same name as the issue found at {{ params.gh_url }}

    ## Phase 1: Task Analysis
    1. Using the `gh` CLI load the GitHub issue at {{ params.gh_url }} (eg. `gh issue view {{ params.gh_url }}`)
    2. Summarize the task requirements and constraints in your own words
    3. Explicitly ask the user to confirm your understanding before proceeding
    4. Identify any ambiguities or points requiring clarification and ask about them
    5. Once your understanding of the issue has been confirmed, write a summary to your note file.
    
    ## Phase 2: Solution Design
    1. Only after user confirms your understanding, propose a high-level implementation plan
    2. Discuss design alternatives and tradeoffs
    3. Ask for feedback on your proposed approach
    4. Work with the user to refine the implementation plan
    5. Analyze existing patterns in the codebase to ensure consistency
    6. Check for existing testing practices and documentation standards
    7. Add a new section to your notes document describing the solution we've agreed upon. Include any helpful diagrams in MermaidJS format.
    8. Explicitly request approval before proceeding to implementation

    ## Phase 3: Implementation
    1. ONLY after explicit approval, begin implementing the solution
    2. Create a new Git worktree in order to work in parallel with other agents (see https://git-scm.com/docs/git-worktree)
    3. Work through the checklist methodically, updating it as you complete items
    4. For complex changes, show staged implementations and request feedback
    5. Handle edge cases and add error resilience
    6. Ensure namespaces and imports follow project conventions
    7. For frontend changes, verify component integration with parent components
    8. Test key functionality before marking items as complete
    9. Update the note file with any pertinent information (eg. key decisions, new information, etc.)
    10. Prepare a detailed commit message describing the changes

    ## Phase 4: Review
    1. Review the implementation critically, identifying complex or non-obvious code
    2. Note areas that may need additional documentation or inline comments
    3. Highlight potential future maintenance challenges
    4. Suggest improvements for robustness, performance, or readability
    5. Incorporate your own suggestions if you deem them valuable
    6. Update the note file with anything you learned from the review or change you've made

    ## Phase 5: Submit
    1. Commit your changes in a new branch and push the branch to the remote
    2. Open a new Pull Request with your changes using the `gh` CLI (eg. `gh pr create`)
    3. Base your Pull Request on the `main` branch
    4. Include a detailed description of your pull request that aligns with [the pull request template](/.github/pull_request_template.md)
    5. Add links to your pull request in the notes file

    ## Phase 6: Iterate
    1. Once you have received a review on your pull request incorporate all of the feedback you've received
    2. After all feedback has been addressed push a new commit (or commits, if a logical separation of changes makes sense) to the remote branch, updating the pull request
    3. Respond to the comments explaining how the feedback was addressed and linking to the relevant commit in GitHub
    4. Repeat this process for each round of feedback until the pull request is merged by the repository owner

    ## Phase 7: Reflect
    1. Reflect on anything you have learned during this process, eg.
      - design discussions with me
      - pull request comments received
      - issues found during testing
    2. Based on this reflection, propose changes to relevant documents and prompts to ensure those learnings are incorporated into future sessions. Consider artifacts such as:
      - README.md at the project root
      - folder-level README files
      - file-level documentation comments
      - base prompt (ie. CLAUDE.md)
      - this custom command prompt (ie. .claude/commands/build.md)
    3. Open another pull request with any changes related to your reflection.
    4. Update your notes with anything you've learned.

    # Important Rules
    - NEVER write any implementation code during Phase 1 or 2
    - ALWAYS get explicit approval before moving to each subsequent phase
    - Break down problems into manageable components
    - Consider edge cases and error handling in your design
    - Use research tools to understand the codebase before proposing changes
    - Examine similar functionality in the codebase to follow established patterns
    - Pay special attention to namespace resolution and import patterns
    - When in doubt, clarify with the user rather than making assumptions
    - Include clear acceptance criteria in your implementation plan
    - For full-stack features, test both frontend and backend components together
    - Never commit code directly to the `main` branch
    - Add to your working note whenever you discover new information
    - Whenever you learn something new, ensure that your note file is updated to reflect what you've learned
    - When taking notes include permalinks to both internal and external resources whenever possible
    - Always use MermaidJS when documenting designs or diagramming
    - Keep your note file well organized with proper headings and a sensible information hierarchy
    - Your note file MUST be formatted in markdown
  </instructions>
</prompt>
