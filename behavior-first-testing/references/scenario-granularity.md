# Scenario granularity — meaningful tests, not one per line

The second most common failure mode of AI coding agents writing tests is **organizing tests around the number of lines of code** rather than around behaviors. The result: a 30-line component with 30 trivial tests, each asserting one tiny thing, none of which would catch a real regression.

This reference is the long version of Rule 2 in `SKILL.md`.

## The principle

**Organize tests around meaningful behaviors, situations, or scenarios.** Do not organize the suite around the number of lines of code.

For example, a single focused component test may cover a complete scenario:

- Render a component with realistic data.
- Interact with a control.
- Verify the resulting visible state.
- Verify a relevant callback or externally observable side effect.

This is appropriate when the steps describe one coherent behavior and the assertions collectively prove its contract.

However, do not combine unrelated behaviors into a giant test merely to reduce the test count.

## Granularity rules

- Write **one test per meaningful behavior or scenario**, not one test per assertion or source line.
- Multiple related assertions are encouraged when they establish different aspects of the same outcome.
- Several sequential user actions can belong in one test when they form a coherent user journey or state transition.
- Separate scenarios when they represent:
  - Independently failing behaviors.
  - Distinct requirements.
  - Materially different preconditions.
  - Substantially different failure modes.
- Keep each test short enough that its purpose and failure are easy to understand.
- Prefer descriptive scenario names that explain the behavior and expected outcome.
- Avoid splitting a single scenario into many tiny tests that repeatedly perform the same setup and test the same contract.
- Avoid giant tests that cover unrelated cases and make failures difficult to diagnose.
- Use parameterized tests (`it.each([...])`) when multiple inputs exercise the same rule and the cases benefit from being expressed together.
- Share setup through simple helpers or fixtures when doing so improves clarity without hiding important behavior.
- Do not add tests just to make a diff look more thoroughly tested.

## Assertions — count depends on the scenario

A test may have one assertion or several assertions. The correct number depends on the scenario. **Do not impose arbitrary assertion-count limits.**

For example, a form-submission scenario might reasonably assert that:

1. The user can enter valid information.
2. Submission invokes the expected handler with the correct payload.
3. The success state is rendered.

These assertions can belong in one test because they verify the same end-to-end component behavior.

By contrast, unrelated form validation rules may deserve separate scenarios if they represent independent contracts (e.g., "rejects missing email" vs. "rejects malformed email" vs. "rejects used email" are three distinct contracts).

## Test value — the four questions

Before creating a test, ask:

1. **What real behavior or contract does this test protect?**
2. **What regression would cause it to fail?**
3. **Would a harmless refactor break this test even though the behavior remains correct?**
4. **Is the behavior already adequately covered by another test?**

If a test only proves that a variable exists, an assignment was executed, a class name was added, or a line was called, it usually does not provide meaningful regression protection.

Test implementation details only when those details are intentionally part of a public or externally observable contract.

## Examples

### Good — one test per coherent scenario

```ts
describe("ContactForm", () => {
  it("submits the entered values and renders the success message on valid input", async () => {
    const user = userEvent.setup();
    const onSubmit = vi.fn();
    render(<ContactForm onSubmit={onSubmit} />);

    await user.type(screen.getByLabelText(/name/i), "Ada");
    await user.type(screen.getByLabelText(/email/i), "[email protected]");
    await user.type(screen.getByLabelText(/message/i), "Hello");
    await user.click(screen.getByRole("button", { name: /send/i }));

    expect(onSubmit).toHaveBeenCalledWith({
      name: "Ada",
      email: "[email protected]",
      message: "Hello",
    });
    expect(screen.getByText(/thanks for your message/i)).toBeInTheDocument();
  });

  it("shows a validation error and does not submit when the email is invalid", async () => {
    const user = userEvent.setup();
    const onSubmit = vi.fn();
    render(<ContactForm onSubmit={onSubmit} />);

    await user.type(screen.getByLabelText(/name/i), "Ada");
    await user.type(screen.getByLabelText(/email/i), "not-an-email");
    await user.click(screen.getByRole("button", { name: /send/i }));

    expect(screen.getByText(/please enter a valid email/i)).toBeInTheDocument();
    expect(onSubmit).not.toHaveBeenCalled();
  });
});
```

These two tests are two scenarios with multiple assertions each. They fail or pass for clear, distinct reasons.

### Bad — split into many trivial tests

```ts
describe("ContactForm", () => {
  it("renders the name input", () => {
    render(<ContactForm onSubmit={() => {}} />);
    expect(screen.getByLabelText(/name/i)).toBeInTheDocument();
  });
  it("renders the email input", () => {
    render(<ContactForm onSubmit={() => {}} />);
    expect(screen.getByLabelText(/email/i)).toBeInTheDocument();
  });
  it("renders the message input", () => {
    render(<ContactForm onSubmit={() => {}} />);
    expect(screen.getByLabelText(/message/i)).toBeInTheDocument();
  });
  it("renders the submit button", () => {
    render(<ContactForm onSubmit={() => {}} />);
    expect(screen.getByRole("button", { name: /send/i })).toBeInTheDocument();
  });
  // ... eight more tests that each render the form and assert one thing
});
```

These tests all do the same render, all pass together, and would all break together. They provide no independent regression value. Combine them.

### Good — parameterized test for a single rule

```ts
describe("formatDistance", () => {
  it.each([
    { metres: 0, expected: "0 km" },
    { metres: 499, expected: "0 km" },
    { metres: 500, expected: "1 km" },
    { metres: 1500, expected: "2 km" },
    { metres: 9000, expected: "9 km" },
  ])("rounds $metres m to $expected", ({ metres, expected }) => {
    expect(formatDistance(metres)).toBe(expected);
  });
});
```

All cases exercise one rule ("round to nearest kilometre") with multiple inputs. They belong together.

### Bad — pile unrelated cases into one giant test

```ts
it("handles everything", () => {
  expect(formatDistance(0)).toBe("0 km");
  expect(formatWeight(0)).toBe("0 kg");
  expect(formatDate(0, "UTC")).toBe("1970-01-01");
  expect(formatVolume(0)).toBe("0 m³");
  expect(flagEmoji("US")).toBe("🇺🇸");
  // ...
});
```

Five different functions, one test. A failure in any of them fails the same test. Diagnose later. Don't do this.

## Naming

The `it` description should read like a requirement, not a method name.

```ts
it("works")                                   // useless
it("test computeTotal")            // tests the method, not the behavior
it("sums two positive numbers")                // reads like a spec
it("throws when the cart is empty")            // describes the contract
it("renders the singular label for one point") // scenario, not implementation
```

This repo's existing tests use plain present-tense descriptions ("renders X", "calls Y", "returns Z") without "should" or "when". Match that voice.