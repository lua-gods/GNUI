# GNUI

### 🚧 Project Status
> [!CAUTION]
> There are absolutely no instructions yet on how to properly set this up. this message will disappear once there is, meaning its ready for public testing.

**GNUI** is a modular, framework-agnostic UI library built for **LÖVE** and **Figura**.
It is designed to separate layout logic, styling, and rendering into clean, interchangeable layers.

> ⚠️ GNUI is a personal hobby project of mine! Development is slow and happens in my free time.

---

## ✨ Philosophy

GNUI is built around one core idea:

> **Separate layout, style, and rendering.**

This allows:

* Multiple rendering backends
* Framework-specific integrations
* Reusable layout + styling logic
* Cleaner internal architecture

GNUI is split into **three main module types**:

* **GNUI-Core**
* **GNUI-Shared**
* **GNUI-Renderer**

Each module has a clear responsibility.

---

# 📦 Architecture Overview

```
GNUI-Core  <---->  GNUI-Shared  <---->  GNUI-Renderer
       |                 |                  |
Layout + Input   Styling + Theme     Framework Rendering
```

---

# 🧠 GNUI-Core

**Responsibility:** Layout engine & input system

GNUI-Core:

* Handles element sizing and layout
* Manages hierarchy
* Exposes input handling systems
* Is written per-language (currently Lua only)

### Available:

* **GNUI Core Lua**

GNUI-Core does **not** know anything about rendering.
It calculates *what* should be displayed and *where* — not *how* it is drawn.

---

# 🎨 GNUI-Shared

**Responsibility:** Styling & theming

GNUI-Shared:

* Contains styling instructions
* Provides a lightweight default theme
* Connects to both Core and Renderer
* Helps determine how elements should look and be positioned

### Available:

* **GNUI Shared Lua**

This layer allows:

* Theming support
* Style abstraction
* Cleaner separation between layout and visuals

---

# 🖥️ GNUI-Renderer

**Responsibility:** Rendering backend

The renderer is framework-specific.
It takes instructions from Core + Shared and draws the UI.

### Available Renderers:

* **GNUI Render Figura 3D Renderer**
* **GNUI Render Figura RRT Renderer** *(WIP)*
* **GNUI Render Love2D**

Each renderer:

* Implements drawing logic for its platform
* Translates GNUI elements into framework-native calls
* Does not handle layout logic

---

# Soon Supported Platforms

| Framework           | Status           |
| ------------------- | ---------------- |
| LÖVE 11.5           | Ready        |
| Figura 0.5.x        | Ready        |
| Figura RRT(Render to Texture) Renderer | W.I.P |


---

##  Why This Exists ❤️
This is not meant to compete with large-scale UI frameworks.
It is primarily a personal UI library I use for my projects

**Made with Lua, curiosity, and free time.**
