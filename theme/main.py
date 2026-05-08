import main

try:
    if hasattr(main, 'main'):
        main.main()
    elif hasattr(main, 'run'):
        main.run()
    else:
        print("Modul 'main' berhasil dimuat.")

except Exception as e:
    print(f"Error saat menjalankan: {e}")
