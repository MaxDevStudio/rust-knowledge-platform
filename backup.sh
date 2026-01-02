#!/bin/bash

# ==================================================
# УНІВЕРСАЛЬНИЙ БЕКАП-СКРИПТ ДЛЯ РОЗРОБКИ (Rust та інші)
# Автор: Max Dev + Grok
# Версія: 1.1 (січень 2026)
# Запуск: ./backup.sh
# ==================================================

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_DIR="backups/backup_$TIMESTAMP"

echo "Створюємо бекап від $TIMESTAMP..."

# --------------------------------------------------
# 1. Файловий бекап (копія всіх файлів проєкту)
# --------------------------------------------------
# Використовуємо rsync — він розумний: копіює тільки те, що потрібно,
# і повністю ігнорує все, що в .gitignore (якщо файл існує)
mkdir -p $BACKUP_DIR

if [ -f ".gitignore" ]; then
    rsync -a --exclude-from=.gitignore . $BACKUP_DIR/
    echo "Файловий бекап створено з урахуванням .gitignore: $BACKUP_DIR"
else
    rsync -a --exclude='.git' --exclude='target' --exclude='dist' . $BACKUP_DIR/
    echo "Файловий бекап створено (без .gitignore): $BACKUP_DIR"
fi

# --------------------------------------------------
# 2. Git бекап-бранч (найнадійніший спосіб відновлення)
# --------------------------------------------------
# Створюємо нову гілку з усіма поточними змінами
git checkout -b backup-$TIMESTAMP 2>/dev/null || git checkout backup-$TIMESTAMP
git add .
git commit -m "AUTO BACKUP before risky changes $TIMESTAMP" || echo "Нічого комітити — вже чисто"
git checkout main 2>/dev/null || git checkout master  # Повертаємося на основну гілку

echo "Git backup branch створено: backup-$TIMESTAMP"
echo "Бекап завершено!"

# ==================================================
# ШПАРГАЛКА ДЛЯ НОВАЧКІВ: Як відновлювати проєкт
# ==================================================
#
# 1. Подивитися всі бекапи (гілки):
#    git branch -a | grep backup-
#    Приклад виводу:
#      backup-20260102_123456
#      backup-20260102_130000
#
# 2. Перейти на бекап-гілку:
#    git checkout backup-20260102_123456
#
# 3. Повернути зміни з бекапу в основну гілку:
#    git checkout main
#    git merge backup-20260102_123456    # Злити всі зміни
#    або
#    git cherry-pick <commit-hash>       # Взяти тільки один коміт
#
#    Приклад хеша коміту (виглядає так):
#    a1b2c3d4e5f6789012345678901234567890abcd
#    або коротко: a1b2c3d
#
# 4. Якщо потрібно просто подивитися файли з бекапу (без переходу):
#    git show backup-20260102_123456:path/to/file.rs
#
# 5. Видалити старий бекап (коли впевнений, що не потрібен):
#    git branch -D backup-20260102_123456
#    rm -rf backups/backup_20260102_123456   # файловий бекап
#
# 6. Екстрене відновлення, якщо все пропало:
#    - Знайди папку в backups/ (наприклад backups/backup_20260102_123456)
#    - Скопіюй файли назад: cp -r backups/backup_XXXX/* .
#    - Потім git add . && git commit
#
# 7. Подивитися історію всіх комітів (з хешами):
#    git log --oneline --graph --all
#    Приклад виводу:
#    * a1b2c3d (HEAD -> main) Add Tauri desktop
#    * 9f8e7d6 AUTO BACKUP before risky changes 20260102_123456
#    * 8c7d6e5 Initial MVP workspace
#
# Пам'ятай: з цим скриптом ти завжди в безпеці!
# ==================================================