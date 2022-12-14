Lace
====

- Provides a set of general Ada components intended to ease the development of game, sim and GUI Ada applications.
- Components range from low-level 'events' and 'math' to high-level 'user interface' (ala GTK and QT).
- Potential applications areas include: 3d simulations, games, visualisations and editors.
- Supports distributed applications (DSA - see Annex E of the Ada Language Reference Manual).
- Portable across desktop and embedded platforms.
- Portable across X11 platforms (with ability to slot in Wayland/Windows/OS2 support, at need).
- Requires an Ada12 compiler (ie GCC4.8+ with gnat).
- Requires an implementation of the Ada POSIX API (i.e. FLORIST).
- Several additional components are in a private prototype repository (some are more up to date than others). 
- Main idea is to tidy/add each component, in turn, beginning with the base tier.

Content
=======

   - Components are organised into dependency tiers (ie layers).
   - Each component in a tier can only depend on components in lower tiers.

   - Diagram: 'lace/document/components/lace-components.png'.

|Tier    |Component  |Description                                                      |
|--------|-----------|-----------------------------------------------------------------|
|5 ~ Top |User Applet|The user application                                             |
|4 ~ High|mmi        |Man Machine Interface (with OpenGL based rendering).             |
|3 ~ Mid |opengl     |OpenGL rendering support (2d/3d).                                |
|        |physics    |Physics space/dynamics support (2d/3d).                          |
|2 ~ Low |collada    |Provides a Collada parser.                                       |
|1 ~ Base|lace       |Provides core types and a namespace for the Lace package family. |
|        |lace/events|Provides an event mechanism for event-driven architectures.      |
|        |math       |Provides core math functionality.                                |
|        |xml        |Provides a simple XML parser.                                    |


Lace/events additionally:
- Provides Subject, Observer, Event and Response abstractions.
- Supports DSA.
- See  http://en.wikipedia.org/wiki/Event-driven_architecture
- and  http://en.wikipedia.org/wiki/Event-driven_programming
   

Installation
============
The development packages for the following projects need to be installed on your OS.

- Box2d
- Bullet3d
- Florist
- Freetype
- Expat
- X11

Example for Debian/Ubuntu:

```
apt-get install libbullet-dev libbox2d-dev libflorist2016-dev libfreetype6-dev libexpat1-dev libx11-dev
```

The Lumen project is also required:

`$ git clone https://github.com/karakalo/lumen.git`


The cBound ada bindings project is also required:

`$ git clone https://github.com/charlie5/cBound.git`


Adding the following lines to ~/.bashrc (or equivalent) will set the GPR_PROJECT_PATH for all gnat project files:

```bash
export opengl_profile=desk
export opengl_platform=glx
export restrictions=xgc
export OS=Linux
export FLORIST_BUILD=default

export LUMEN=/path/to/lumen
GPR_PROJECT_PATH=$LUMEN:$GPR_PROJECT_PATH

export CBOUND=/path/to/cBound
source $CBOUND/cbound-gpr_paths.sh

export LACE=/path/to/lace
source $LACE/lace-gpr_paths.sh
```

Of course, substitute  /path/to  with the actual paths you use.

This should allow any Lace component to be 'with'ed in a user applications 'gnat project' file.


Lumen requires the application of a few patches.

- `$ cd $LACE/install`
- `$ ./apply_patches.sh`


Lace/opengl contains a set of assets (fonts, shaders, etc). These need to be available in each openGL demo folder.

- `$ cd $LACE/3-mid/opengl/applet`
- `$ sudo cp create_opengl_assets.sh /usr/local/bin`


Lace/mmi contains a set of assets (fonts, etc). These need to be available in each mmi demo folder.

- `$ cd $LACE/4-high/mmi/applet`
- `$ sudo cp create_mmi_assets.sh /usr/local/bin`


Testing
=======

* `$ cd $LACE/4-high/mmi/applet/demo/skinning/rig`
* `$ create_opengl_assets.sh`
* `$ create_mmi_assets.sh`
* `$ gprbuild -P rig_demo.gpr`
* `$ ./launch_rig_demo`
