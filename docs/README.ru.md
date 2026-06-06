

<p align="center">
<a href="../README.md#vnccs-easy-install">English</a> |
<strong>Русский</strong> |
<a href="README.zh-CN.md#vnccs-easy-install">简体中文</a> |
<a href="README.ja.md#vnccs-easy-install">日本語</a> |
<a href="README.ko.md#vnccs-easy-install">한국어</a> |
<a href="README.es.md#vnccs-easy-install">Español</a> |
<a href="README.pt-BR.md#vnccs-easy-install">Português</a> |
<a href="README.de.md#vnccs-easy-install">Deutsch</a> |
<a href="README.fr.md#vnccs-easy-install">Français</a> |
<a href="README.tr.md#vnccs-easy-install">Türkçe</a> |
<a href="README.vi.md#vnccs-easy-install">Tiếng Việt</a>
</p>

---

<p align="center">
  <img src="VNCCS_LOGO.png" alt="VNCCS" width="360">
</p>

<div align="center">

# VNCCS Easy Install

Портативный Windows-установщик **VNCCS - Visual Novel Character Creation Suite** для **ComfyUI**.

[GitHub VNCCS](https://github.com/AHEKOT/ComfyUI_VNCCS) |
[GitHub VNCCS Utils](https://github.com/AHEKOT/ComfyUI_VNCCS_Utils) |
[Discord](https://discord.com/invite/9Dacp4wvQw) |
[Buy Me a Coffee](https://www.buymeacoffee.com/MIUProject)

</div>

## Что Это

VNCCS Easy Install - это готовая портативная сборка ComfyUI, заточенная под запуск и работу с VNCCS без ручной установки десятков зависимостей.

VNCCS - не просто workflow для одной картинки. Это полный пайплайн создания персонажей для визуальных новелл и похожих проектов: базовый персонаж, клонирование референса, одежда, эмоции, позы, спрайты и организованная библиотека персонажей.

Этот форк сохраняет удобную Windows-основу ComfyUI-Easy-Install, но дефолтные ноды, документация и точка входа теперь ориентированы на VNCCS.

## Сильные Стороны VNCCS

- Полный цикл работы с персонажем вместо набора разрозненных workflow.
- Консистентность персонажа между базовыми листами, костюмами, эмоциями, позами и финальными спрайтами.
- VNCCS Control Center для загрузки и выбора Qwen Image Edit 2511 моделей, LoRA, VAE, текстового энкодера и апскейлера.
- VNCCS Pose Studio: интерактивная 3D-сцена для позинга, кадрирования, света и библиотеки поз прямо внутри ComfyUI.
- Character Cloner для сборки VNCCS-персонажа по уже существующим изображениям.
- Clothes Designer для создания и клонирования костюмов с сохранением идентичности персонажа.
- Emotion Studio для генерации наборов эмоций и готовых спрайтов.
- Model Manager и Model Selector для управления LoRA и checkpoint-файлами из HuggingFace/Civitai-репозиториев.

VNCCS сохраняет персонажей здесь:

```text
ComfyUI/output/VNCCS/Characters/YOUR_CHARACTER_NAME
```

Эту папку стоит регулярно бэкапить: это библиотека твоих персонажей.

## Что Устанавливается

| Пакет | Зачем он нужен |
|---|---|
| [ComfyUI](https://github.com/Comfy-Org/ComfyUI) | Основная node-среда |
| [ComfyUI Manager](https://github.com/Comfy-Org/ComfyUI-Manager) | Управление нодами и обновлениями |
| [ComfyUI_VNCCS](https://github.com/AHEKOT/ComfyUI_VNCCS), ставится как `vnccs` | Основной Visual Novel Character Creation Suite |
| [ComfyUI_VNCCS_Utils](https://github.com/AHEKOT/ComfyUI_VNCCS_Utils), ставится как `vnccs-utils` | Pose Studio, Visual Camera Control, QWEN Detailer, Model Manager, Model Selector |
| [ComfyUI-GGUF](https://github.com/city96/ComfyUI-GGUF) | Загрузка GGUF Qwen-моделей для VNCCS Control Center |
| [ComfyUI-Impact-Pack](https://github.com/ltdrdata/ComfyUI-Impact-Pack) | Detector, SAM и FaceDetailer-пути, используемые VNCCS |
| [ComfyUI-SeedVR2_VideoUpscaler](https://github.com/numz/ComfyUI-SeedVR2_VideoUpscaler) | Дефолтный режим апскейла VNCCS |
| [ComfyUI-Easy-Sam3](https://github.com/yolain/ComfyUI-Easy-Sam3) | Preprocessing для clone clothes |
| [quick-connections](https://github.com/niknah/quick-connections) | Удобное расширение интерфейса для быстрых соединений |

Старый широкий набор нод из дефолтного Easy Install / Pixaroma тут не ставится по умолчанию. Сборка оставляет только то, что нужно VNCCS и его рабочим сценариям.

## Основные Workflow

После установки открой в ComfyUI workflow из VNCCS:

1. `VNCCS_3.0_Step1_CharacterCreator.json` - создание базового персонажа.
2. `VNCCS_3.0_Step1_CharacterCloner.json` - клонирование персонажа по референсам.
3. `VNCCS_3.0_Step2_CharacterClothes.json` - создание или клонирование одежды.
4. `VNCCS_3.0_Step3_CharacterEmotions.json` - генерация эмоций и спрайтов.
5. `VNCCS_MigrationAssistent.json` - миграция персонажей из старых версий VNCCS.

Практический путь:

```text
Создать или клонировать персонажа -> Сгенерировать одежду -> Сгенерировать эмоции -> Использовать спрайты в визуальной новелле
```

## Модели

VNCCS 3.0 использует **VNCCS Control Center**. Открой любой workflow VNCCS и нажми **Download ALL**, чтобы разложить основные модели по нужным папкам ComfyUI.

Основной путь генерации - Qwen Image Edit 2511 через GGUF. Control Center управляет:

- Qwen Image Edit 2511 GGUF: Q4, Q5, Q8.
- QIE2511 text encoder и VAE.
- Qwen Image Edit 2511 Lightning LoRA.
- VNCCS Clothes Core LoRA.
- VNCCS Emotion Core LoRA.
- VNCCS Pose Studio LoRA.
- 4x APISR upscaler.

Character Cloner и clothing wizard также могут использовать Qwen2.5-VL helper GGUF для описания изображений. В интерфейсе есть отдельные кнопки загрузки.

## Установка На Windows

1. Распакуй VNCCS Easy Install в новую папку.
2. Запусти `ComfyUI-Easy-Install.bat`.
3. Не запускай установщик от имени администратора.
4. Не ставь сборку в `Program Files`, `Windows` или корень `C:\`.
5. Лучше избегать пробелов и спецсимволов в пути.
6. Обнови NVIDIA-драйверы.

После установки запускай ComfyUI через `Start ComfyUI.bat` или EZi Desktop launcher.

## Полезные Инструменты

В сборке оставлены полезные инструменты Easy Install:

- Easy-Models-Linker для подключения существующей папки моделей через `extra_model_paths.yaml`.
- Easy-System-Checker для проверки железа и окружения.
- ComfyUI-Version-Switcher для отката ComfyUI при проблемах.
- Easy-model2GGUF для конвертации и квантизации моделей.
- Long-Paths-Enabler для включения длинных путей Windows.
- Torch-Pack для переключения поддерживаемых PyTorch/CUDA сборок.
- Update Easy-Install для обновления helper-файлов.

## Сообщество И Поддержка VNCCS

[Discord VNCCS](https://discord.com/invite/9Dacp4wvQw)

[![Buy Me a Coffee](https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png)](https://www.buymeacoffee.com/MIUProject)

VNCCS - независимый проект. Поддержка помогает развивать пайплайн персонажей, Pose Studio, инструменты моделей и документацию.

## Репозитории VNCCS

- Основная нода: [AHEKOT/ComfyUI_VNCCS](https://github.com/AHEKOT/ComfyUI_VNCCS)
- Утилиты: [AHEKOT/ComfyUI_VNCCS_Utils](https://github.com/AHEKOT/ComfyUI_VNCCS_Utils)

## Credits: Оригинальный Инсталлер

Этот проект основан на **ComfyUI-Easy-Install** от **Tavris1 / ivo**. Оригинальный инсталлер дал сборке портативную Windows-основу ComfyUI, EZi Desktop, update-скрипты, add-on инструменты и общий dependency-management flow.

- Репозиторий: [Tavris1/ComfyUI-Easy-Install](https://github.com/Tavris1/ComfyUI-Easy-Install)
- Релизы: [ComfyUI-Easy-Install releases](https://github.com/Tavris1/ComfyUI-Easy-Install/releases)
- macOS / Linux branch: [MAC-Linux](https://github.com/Tavris1/ComfyUI-Easy-Install/tree/MAC-Linux)

Поддержать автора оригинального инсталлера:

[![PayPal](https://img.shields.io/badge/PayPal-00457C?style=for-the-badge&logo=paypal&logoColor=white)](https://paypal.me/tavris1)
[![Buy Me a Coffee](https://img.shields.io/badge/Buy_Me_A_Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black)](https://buymeacoffee.com/tavris1)
[![GitHub Sponsors](https://img.shields.io/badge/Sponsor-30363D?style=for-the-badge&logo=GitHub-Sponsors&logoColor=white)](https://github.com/sponsors/Tavris1)
