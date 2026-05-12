"""
Generates memoria_outventura_v2.icml — InCopy Markup Language file.
Import in InDesign via File > Place.
All text comes in with paragraph styles ready to apply.
"""

import xml.etree.ElementTree as ET
from xml.dom import minidom

# ── Outventura colors (hex) ────────────────────────────────────────────────────
PRIMARY       = "588C23"
DARK_GREEN    = "3B593F"
LIGHT_GREEN   = "AFD68D"
SECONDARY     = "A6774E"
TERTIARY      = "324756"
WHITE         = "FFFFFF"
DARK          = "201814"
GRAY          = "555555"
LIGHT_GRAY    = "999999"
ERROR_RED     = "B53A3A"


def hex_to_cmyk_approx(hex_color):
    """Rough hex→CMYK for InDesign color definitions."""
    r = int(hex_color[0:2], 16) / 255
    g = int(hex_color[2:4], 16) / 255
    b = int(hex_color[4:6], 16) / 255
    k = 1 - max(r, g, b)
    if k == 1:
        return (0, 0, 0, 100)
    c = (1 - r - k) / (1 - k) * 100
    m = (1 - g - k) / (1 - k) * 100
    y = (1 - b - k) / (1 - k) * 100
    return (round(c), round(m), round(y), round(k * 100))


class ICMLBuilder:
    """Builds an ICML (InCopy XML) document."""

    def __init__(self):
        self.paragraphs = []  # list of (style_name, runs)
        # runs = list of (char_style, text)

    # ── Content methods ────────────────────────────────────────────────────

    def add_para(self, style, text, char_style=None):
        cs = char_style or "$ID/[No character style]"
        self.paragraphs.append((style, [(cs, text)]))

    def add_para_runs(self, style, runs):
        """runs = [(char_style, text), ...]"""
        self.paragraphs.append((style, runs))

    def heading1(self, text):
        self.add_para("Heading1", text)

    def heading2(self, text):
        self.add_para("Heading2", text)

    def heading3(self, text):
        self.add_para("Heading3", text)

    def body(self, text, bold=False):
        cs = "Bold" if bold else "$ID/[No character style]"
        self.add_para("Body", text, cs)

    def bullet(self, text):
        self.add_para("Bullet", text)

    def code(self, text):
        self.add_para("Code", text)

    def table_row(self, cells, is_header=False):
        style = "TableHeader" if is_header else "TableCell"
        row_text = "  |  ".join(cells)
        self.add_para(style, row_text)

    def img_placeholder(self, desc):
        self.add_para("ImagePlaceholder", f"[ IMAGEN: {desc} ]")

    def page_break(self):
        self.add_para("PageBreak", "")

    # ── XML generation ─────────────────────────────────────────────────────

    def build_xml(self):
        root = ET.Element("Document")
        root.set("DOMVersion", "8.0")
        root.set("Self", "d")

        # ── Colors ──
        colors_data = [
            ("Primary",    PRIMARY),
            ("DarkGreen",  DARK_GREEN),
            ("LightGreen", LIGHT_GREEN),
            ("Secondary",  SECONDARY),
            ("Tertiary",   TERTIARY),
            ("Dark",       DARK),
            ("Gray",       GRAY),
            ("LightGray",  LIGHT_GRAY),
            ("ErrorRed",   ERROR_RED),
        ]
        for name, hex_c in colors_data:
            c, m, y, k = hex_to_cmyk_approx(hex_c)
            el = ET.SubElement(root, "Color")
            el.set("Self", f"Color/{name}")
            el.set("Name", name)
            el.set("Model", "Process")
            el.set("Space", "CMYK")
            el.set("ColorValue", f"{c} {m} {y} {k}")

        # Black and Paper (required)
        for name, vals in [("Black", "0 0 0 100"), ("Paper", "0 0 0 0")]:
            el = ET.SubElement(root, "Color")
            el.set("Self", f"Color/{name}")
            el.set("Name", name)
            el.set("Model", "Process")
            el.set("Space", "CMYK")
            el.set("ColorValue", vals)

        # ── Character Styles ──
        char_styles = [
            ("$ID/[No character style]", "[No character style]", {}),
            ("Bold", "Bold", {"FontStyle": "Bold"}),
            ("Italic", "Italic", {"FontStyle": "Italic"}),
            ("BoldItalic", "BoldItalic", {"FontStyle": "Bold Italic"}),
            ("CodeInline", "CodeInline", {"AppliedFont": "Consolas", "PointSize": "9", "FillColor": "Color/Tertiary"}),
        ]
        for self_id, name, props in char_styles:
            el = ET.SubElement(root, "CharacterStyle")
            el.set("Self", f"CharacterStyle/{self_id}")
            el.set("Name", name)
            for k, v in props.items():
                el.set(k, v)

        # ── Paragraph Styles ──
        para_styles = [
            ("$ID/[No paragraph style]", "[No paragraph style]", {}),
            ("Heading1", "Heading1", {
                "AppliedFont": "Montserrat",
                "FontStyle": "Bold",
                "PointSize": "22",
                "FillColor": "Color/Primary",
                "SpaceBefore": "24",
                "SpaceAfter": "12",
            }),
            ("Heading2", "Heading2", {
                "AppliedFont": "Montserrat",
                "FontStyle": "Bold",
                "PointSize": "16",
                "FillColor": "Color/DarkGreen",
                "SpaceBefore": "18",
                "SpaceAfter": "8",
            }),
            ("Heading3", "Heading3", {
                "AppliedFont": "Montserrat",
                "FontStyle": "Bold",
                "PointSize": "13",
                "FillColor": "Color/Secondary",
                "SpaceBefore": "12",
                "SpaceAfter": "6",
            }),
            ("Body", "Body", {
                "AppliedFont": "Open Sans",
                "FontStyle": "Regular",
                "PointSize": "11",
                "SpaceAfter": "6",
            }),
            ("Bullet", "Bullet", {
                "AppliedFont": "Open Sans",
                "FontStyle": "Regular",
                "PointSize": "11",
                "SpaceAfter": "4",
                "LeftIndent": "18",
                "FirstLineIndent": "-12",
                "BulletsAndNumberingListType": "BulletList",
            }),
            ("Code", "Code", {
                "AppliedFont": "Consolas",
                "FontStyle": "Regular",
                "PointSize": "9",
                "FillColor": "Color/Tertiary",
                "SpaceAfter": "8",
                "LeftIndent": "28",
            }),
            ("TableHeader", "TableHeader", {
                "AppliedFont": "Open Sans",
                "FontStyle": "Bold",
                "PointSize": "9",
                "FillColor": "Color/Paper",
                "SpaceAfter": "2",
            }),
            ("TableCell", "TableCell", {
                "AppliedFont": "Open Sans",
                "FontStyle": "Regular",
                "PointSize": "9",
                "SpaceAfter": "2",
            }),
            ("ImagePlaceholder", "ImagePlaceholder", {
                "AppliedFont": "Open Sans",
                "FontStyle": "Italic",
                "PointSize": "10",
                "FillColor": "Color/LightGray",
                "Justification": "CenterAlign",
                "SpaceBefore": "12",
                "SpaceAfter": "12",
            }),
            ("CoverTitle", "CoverTitle", {
                "AppliedFont": "Montserrat",
                "FontStyle": "Bold",
                "PointSize": "36",
                "FillColor": "Color/Primary",
                "Justification": "CenterAlign",
            }),
            ("CoverSubtitle", "CoverSubtitle", {
                "AppliedFont": "Open Sans",
                "FontStyle": "Italic",
                "PointSize": "14",
                "FillColor": "Color/Secondary",
                "Justification": "CenterAlign",
            }),
            ("CoverInfo", "CoverInfo", {
                "AppliedFont": "Montserrat",
                "FontStyle": "Regular",
                "PointSize": "12",
                "FillColor": "Color/DarkGreen",
                "Justification": "CenterAlign",
            }),
            ("CoverInfoBold", "CoverInfoBold", {
                "AppliedFont": "Montserrat",
                "FontStyle": "Bold",
                "PointSize": "13",
                "FillColor": "Color/DarkGreen",
                "Justification": "CenterAlign",
            }),
            ("PageBreak", "PageBreak", {
                "AppliedFont": "Open Sans",
                "PointSize": "2",
                "SpaceBefore": "0",
                "SpaceAfter": "0",
            }),
            ("IndexEntry", "IndexEntry", {
                "AppliedFont": "Open Sans",
                "FontStyle": "Regular",
                "PointSize": "11",
                "SpaceAfter": "2",
            }),
            ("Reference", "Reference", {
                "AppliedFont": "Open Sans",
                "FontStyle": "Regular",
                "PointSize": "10",
                "SpaceAfter": "3",
            }),
        ]
        for self_id, name, props in para_styles:
            el = ET.SubElement(root, "ParagraphStyle")
            el.set("Self", f"ParagraphStyle/{self_id}")
            el.set("Name", name)
            for k, v in props.items():
                el.set(k, v)

        # ── Story (main content) ──
        story = ET.SubElement(root, "Story")
        story.set("Self", "story_main")
        story.set("StoryTitle", "Memòria Outventura")
        story.set("TrackChanges", "false")

        for i, (style, runs) in enumerate(self.paragraphs):
            psr = ET.SubElement(story, "ParagraphStyleRange")
            psr.set("AppliedParagraphStyle", f"ParagraphStyle/{style}")

            for char_style, text in runs:
                csr = ET.SubElement(psr, "CharacterStyleRange")
                csr.set("AppliedCharacterStyle", f"CharacterStyle/{char_style}")
                content = ET.SubElement(csr, "Content")
                content.text = text

            # Add line break between paragraphs (except last)
            if i < len(self.paragraphs) - 1:
                br = ET.SubElement(psr, "Br")

        return root

    def save(self, path):
        root = self.build_xml()
        rough = ET.tostring(root, encoding="unicode", xml_declaration=False)
        # Add processing instructions
        header = (
            '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>\n'
            '<?aid style="50" type="snippet" readerVersion="6.0" '
            'featureSet="513" product="8.0(370)" ?>\n'
        )
        # Pretty print
        dom = minidom.parseString(rough)
        pretty = dom.toprettyxml(indent="  ", encoding=None)
        # Remove minidom's xml declaration (we add our own)
        lines = pretty.split("\n")
        if lines[0].startswith("<?xml"):
            lines = lines[1:]
        body_xml = "\n".join(lines)

        with open(path, "w", encoding="utf-8") as f:
            f.write(header)
            f.write(body_xml)

        print(f"ICML generat: {path}")


# ══════════════════════════════════════════════════════════════════════════════
#  BUILD DOCUMENT CONTENT
# ══════════════════════════════════════════════════════════════════════════════

doc = ICMLBuilder()

# ── PORTADA ──
doc.add_para("CoverInfoBold", "Manuel Navalon Fornes")
doc.add_para("Body", "")
doc.img_placeholder("LOGO OUTVENTURA (icono de muntanya amb text)")
doc.add_para("Body", "")
doc.add_para("CoverTitle", "OUTVENTURA")
doc.add_para("CoverSubtitle", "L'aventura al teu abast")
doc.add_para("Body", "")
doc.add_para("Body", "")
doc.add_para("CoverInfoBold", "CFGS DAW")
doc.add_para("CoverInfo", "Mòdul Professional Projecte Intermodular")
doc.add_para("CoverInfo", "Desenvolupament d'Aplicacions Multiplataforma")
doc.add_para("CoverInfoBold", "IES L'ESTACIÓ")
doc.add_para("CoverInfo", "Curs 2025-26")
doc.add_para("Body", "")
doc.add_para("CoverInfo", "Alumne: Manuel Navalon Fornes")
doc.add_para("CoverInfo", "Tutor: __________________________")
doc.page_break()

# ── ÍNDEX ──
doc.heading1("Índex")
index_entries = [
    "1.  Introducció",
    "    1.1  Idea de negoci",
    "    1.2  Objectius",
    "    1.3  Anàlisi del mercat i segmentació. Competència. DAFO",
    "    1.4  Alineació amb ODS",
    "2.  Anàlisi dels requeriments",
    "    2.1  Entitat Relació",
    "    2.2  Diagrama de classes i casos d'ús",
    "    2.3  Disseny",
    "        2.3.1  Mockups",
    "        2.3.2  Paleta de colors",
    "        2.3.3  Usabilitat",
    "    2.4  Tecnologies",
    "        2.4.1  Desplegament",
    "        2.4.2  Backend",
    "        2.4.3  Frontend",
    "        2.4.4  Disseny",
    "    2.5  Planificació",
    "        2.5.1  Diagrama de Gantt",
    "3.  Implementació",
    "    3.1  Desplegament",
    "    3.2  Backend",
    "    3.3  Frontend",
    "    3.4  Disseny",
    "4.  Millores futures",
    "5.  Conclusions",
    "    5.1  Personals",
    "    5.2  Tècniques",
    "6.  Referències bibliogràfiques",
]
for e in index_entries:
    doc.add_para("IndexEntry", e)
doc.page_break()

# ── 1. INTRODUCCIÓ ──
doc.heading1("1. Introducció")

doc.heading2("1.1 Idea de negoci")
doc.body(
    "Outventura és una aplicació mòbil destinada a empreses i associacions que "
    "organitzen activitats a l'aire lliure: excursions de muntanya, rutes aquàtiques, "
    "sortides de neu i acampades. Neix per donar solució a la gestió manual "
    "(excels, WhatsApp, paper) que encara fan servir moltes d'aquestes entitats."
)
doc.body(
    "L'app ofereix dos grans blocs funcionals: d'una banda, la gestió del catàleg "
    "d'excursions i del material d'aventura per part dels administradors; de l'altra, "
    "la consulta, sol·licitud i reserva per part dels clients. A més, incorpora "
    "la figura de l'expert (guia assignat) que pot gestionar les sol·licituds "
    "que li arriben."
)
doc.body(
    "El model de negoci es basa en: (1) preu per participant en cada excursió, "
    "(2) lloguer diari de material i (3) càrrec per danys en la devolució. Tot "
    "automatitzat i visible dins l'app, tant per a l'admin com per al client."
)

doc.heading2("1.2 Objectius")
doc.body("Objectius funcionals:", bold=True)
doc.bullet("Gestió completa d'excursions: crear, editar, eliminar, filtrar per categoria/data/estat.")
doc.bullet("Gestió d'equipament: inventari, preus de lloguer, estats (disponible, agotado, mantenimiento, fora de servei).")
doc.bullet("Sistema de sol·licituds: el client sol·licita participar en una excursió, l'admin o expert l'accepta o rebutja.")
doc.bullet("Sistema de reserves de material: lligat a sol·licituds o independent, amb control de danys en la devolució.")
doc.bullet("Calendari: vista mensual amb excursions, reserves i sol·licituds.")
doc.bullet("Autenticació JWT amb rols (SUPERADMIN, ADMIN, EXPERTO, USUARIO, INVITADO).")
doc.body("Objectius tècnics:", bold=True)
doc.bullet("App multiplataforma (Android + iOS) amb Flutter i Dart.")
doc.bullet("Backend REST amb NestJS, TypeScript, Prisma ORM i PostgreSQL.")
doc.bullet("Documentació de la API amb Swagger (OpenAPI).")
doc.bullet("Entorn containeritzat amb Docker Compose (BD + pgAdmin).")
doc.bullet("Arquitectura neta al frontend (Clean Architecture) i modular al backend.")
doc.bullet("UI coherent amb sistema de tema (clar/fosc) i design system intern.")

doc.heading2("1.3 Anàlisi del mercat i segmentació. Competència. DAFO")
doc.body(
    "El sector del turisme actiu a Espanya supera els 4.500 milions d'euros "
    "anuals i creix un 8% interanual. Tanmateix, la majoria d'empreses petites "
    "encara gestionen les reserves per telèfon o formularis web genèrics."
)
doc.body("Competència directa i indirecta:", bold=True)
doc.table_row(["Competidor", "Què fa", "Limitació respecte Outventura"], is_header=True)
doc.table_row(["Civitatis", "Marketplace d'activitats turístiques", "No gestiona material ni equips interns"])
doc.table_row(["Wikiloc", "Rutes GPS compartides", "No té reserves ni gestió empresarial"])
doc.table_row(["Fareharbor", "Reserves online per operadors", "Preu alt, no open source, sense inventari"])
doc.table_row(["Google Forms", "Formularis genèrics", "Zero automatització, sense dashboard"])

doc.body("Segmentació del mercat:", bold=True)
doc.bullet("Empreses d'activitats a l'aire lliure (escalada, kayak, senderisme).")
doc.bullet("Associacions esportives amb magatzem de material.")
doc.bullet("Centres d'esplai, colònies i grups escolars.")
doc.bullet("Clubs de muntanya i guies independents.")

doc.body("Anàlisi DAFO:", bold=True)
doc.table_row(["", "Positiu", "Negatiu"], is_header=True)
doc.table_row(["Intern",
    "Fortaleses: Solució integral (gestió + client), UI moderna Material 3, Arquitectura escalable i modular, Multiplataforma amb un sol codebase",
    "Debilitats: Desenvolupador únic (temps limitat), Backend en construcció parcial, Sense integració de pagament real, Tests limitats"])
doc.table_row(["Extern",
    "Oportunitats: Mercat en creixement post-COVID, Poca competència directa low-cost, Digitalització obligada del sector, Possible SaaS multi-tenant",
    "Amenaces: Apps genèriques de gestió, Cost d'adquisició de clients B2B, Dependència de stores (Apple/Google), Canvis en APIs de tercers"])

doc.heading2("1.4 Alineació amb objectius, valors, sostenibilitat i futur (ODS)")
doc.body("El projecte s'alinea amb els següents Objectius de Desenvolupament Sostenible:")
doc.bullet("ODS 3 — Salut i benestar: promou l'activitat física i la connexió amb la natura.")
doc.bullet("ODS 8 — Treball decent: digitalitza i professionalitza el sector, creant valor per a guies i petites empreses.")
doc.bullet("ODS 11 — Comunitats sostenibles: fomenta el turisme local i de proximitat.")
doc.bullet("ODS 12 — Consum responsable: el control d'inventari evita compres innecessàries i allarga la vida del material.")
doc.bullet("ODS 13 — Acció climàtica: redueix el paper i promou activitats de baix impacte ambiental.")
doc.body(
    "Valors de marca: accessibilitat (activitats per a tots els nivells), "
    "seguretat (control de material i guies qualificats), respecte ambiental "
    "i transparència (preus clars, sense sorpreses)."
)
doc.page_break()

# ── 2. ANÀLISI DELS REQUERIMENTS ──
doc.heading1("2. Anàlisi dels requeriments")

doc.heading2("2.1 Entitat Relació")
doc.body(
    "La base de dades relacional (PostgreSQL 16) es gestiona amb Prisma ORM. "
    "S'ha dissenyat amb 6 entitats principals:"
)
doc.table_row(["Entitat", "PK", "Camps principals", "Relacions"], is_header=True)
doc.table_row(["Role", "id_role", "code (UNIQUE), description", "1:N → User"])
doc.table_row(["User", "id_user", "name, surname, email (UNIQUE), phone, photo, password, status, timestamps", "N:1 → Role"])
doc.table_row(["Category", "id_category", "code (UNIQUE), description", "M:N → Equipment, M:N → Activity"])
doc.table_row(["EquipmentStatus", "id_status", "code (UNIQUE), description", "1:N → Equipment"])
doc.table_row(["Equipment", "id_equipment", "title, description, price_per_day, units", "N:1 → EquipmentStatus, M:N → Category"])
doc.table_row(["Activity", "id_activity", "title, description, init_date, end_date, difficulty, max_participants, start_end_point", "M:N → Category"])

doc.body(
    "Les relacions molts-a-molts (Category ↔ Equipment, Category ↔ Activity) es "
    "gestionen amb taules intermèdies implícites de Prisma. El camp difficulty "
    "d'Activity és un enter de 0 a 100 que representa el percentatge de dificultat."
)
doc.img_placeholder("DIAGRAMA E/R complet: Role, User, Category, Activity, Equipment, EquipmentStatus amb cardinalitats, PKs i FKs")

doc.heading2("2.2 Diagrama de classes i casos d'ús")
doc.body("Entitats del domini Flutter (capa domain/entities):", bold=True)
doc.table_row(["Classe", "Atributs principals", "Enums associats"], is_header=True)
doc.table_row(["Excursion", "id, puntoInicio, puntoFin, imagenAsset, fechaInicio/Fin, categorias, numeroParticipantes, descripcion, precio, materialesPorParticipante", "EstadoExcursion (disponible, pendiente, confirmada, enCurso, finalizada, cancelada)"])
doc.table_row(["Equipamiento", "id, nombre, descripcion, categorias, stock, stockTotal, estado, precioAlquilerDiario, cargoPorDanio, imagenAsset", "EstadoEquipamiento (disponible, agotado, mantenimiento, fueraDeServicio)"])
doc.table_row(["Solicitud", "id, idExcursion, numeroParticipantes, estado, idExperto, idUsuario, idReserva, materialesSolicitados, precioTotal", "EstadoSolicitud (pendiente, confirmada, enCurso, finalizada, cancelada)"])
doc.table_row(["Reserva", "id, idUsuario, lineas (List<LineaReserva>), idExcursion, fechaInicio/Fin, estado, cargoDanios, itemsDaniados", "EstadoReserva (pendiente, confirmada, enCurso, finalizada, cancelada)"])
doc.table_row(["Usuario", "id, nombre, apellidos, email, telefono, rol, foto, activo", "TipoRol (superadmin, admin, experto, usuario, invitado)"])
doc.table_row(["CategoriaActividad", "—", "acuatico, nieve, montana, camping"])

doc.img_placeholder("DIAGRAMA DE CLASSES UML: totes les entitats del domini Flutter amb atributs, mètodes factory i relacions")

doc.body("Casos d'ús per actor:", bold=True)
doc.table_row(["Actor", "Casos d'ús principals"], is_header=True)
doc.table_row(["Invitat", "Consultar catàleg d'excursions · Consultar catàleg de material"])
doc.table_row(["Usuari", "Login · Sol·licitar excursió · Reservar material · Veure historial · Editar perfil · Canviar contrasenya"])
doc.table_row(["Expert", "Gestionar sol·licituds assignades · Canviar estat de sol·licitud · Veure calendari"])
doc.table_row(["Admin", "CRUD excursions · CRUD material · CRUD usuaris · Gestionar reserves · Gestionar sol·licituds · Assignar experts · Aprovar/rebutjar reserves · Registrar devolucions"])
doc.table_row(["Superadmin", "Tot l'anterior + Gestionar admins + Configuració global del sistema"])
doc.img_placeholder("DIAGRAMA DE CASOS D'ÚS UML: 5 actors amb les seves accions dins del sistema")

doc.heading2("2.3 Disseny")

doc.heading3("2.3.1 Mockups")
doc.body(
    "L'app compta amb 17 pantalles principals, dissenyades amb Material Design 3 "
    "i adaptades a la identitat visual d'Outventura."
)
doc.body("Flux d'autenticació:", bold=True)
doc.bullet("Login: fons amb imatge de paisatge (Camino.jpg), card semitransparent amb email + password, toggle de visibilitat, enllaços a registre i forgot password.")
doc.bullet("Perfil: edició de dades personals + canvi de contrasenya amb validació en temps real.")

doc.body("Flux de client:", bold=True)
doc.bullet("Home Client: salutació personalitzada, estadístiques (reserves, sol·licituds, pendents), sol·licituds recents i noves excursions.")
doc.bullet("Sol·licitar excursió: selecció d'excursió, nombre de participants, recalcul automàtic de materials recomanats, càlcul de preu total.")
doc.bullet("Reservar material: selecció de dates, línies de material (equipament + quantitat), preu total.")

doc.body("Flux d'administració:", bold=True)
doc.bullet("Home Admin: estadístiques globals, botons de gestió ràpida, sol·licituds pendents.")
doc.bullet("CRUD Excursions: formulari amb punt inici/fi, dates, hores, dificultad, participants, preu, categories (múltiples), imatge.")
doc.bullet("CRUD Material: formulari amb nom, descripció, stock, preu lloguer, càrrec per dany, categories, estat, imatge.")
doc.bullet("CRUD Usuaris: formulari amb dades personals, rol (dropdown), estat actiu/inactiu.")
doc.bullet("Gestió Reserves: aprovar, rebutjar, cancelar, registrar devolució (amb selecció d'ítems danyats).")
doc.bullet("Gestió Sol·licituds: acceptar, rebutjar, assignar expert.")

doc.body("Vista compartida:", bold=True)
doc.bullet("Calendari: vista mensual amb badges 'R' (reserves) i 'S' (sol·licituds), llistat d'events del dia seleccionat.")

doc.img_placeholder("MOCKUPS: pantalla de Login (amb fons Camino.jpg) + Home Client + Home Admin")
doc.img_placeholder("MOCKUPS: Catàleg d'excursions amb filtres + Detall excursió + Formulari excursió")
doc.img_placeholder("MOCKUPS: Catàleg de material + Formulari material + Vista calendari")
doc.img_placeholder("MOCKUPS: Sol·licituds + Detall sol·licitud + Formulari sol·licitud")
doc.img_placeholder("MOCKUPS: Reserves + Detall reserva (amb línies) + Formulari reserva")
doc.img_placeholder("MOCKUPS: Gestió d'usuaris + Formulari usuari + Perfil personal")

doc.heading3("2.3.2 Paleta de colors")
doc.body(
    "La paleta està inspirada en la natura i l'aventura. S'han definit dos temes "
    "complets (clar i fosc) amb suficient contrast per complir WCAG AA."
)
doc.table_row(["Nom", "Clar (hex)", "Fosc (hex)", "Ús"], is_header=True)
doc.table_row(["Primary", "#588C23", "#7BAF46", "Botons principals, accents, FABs"])
doc.table_row(["Primary Container", "#AFD68D", "#587936", "Fons de cards actives, xips seleccionats"])
doc.table_row(["Surface Container", "#3B593F", "#6FAF77", "AppBar, headers, menú lateral"])
doc.table_row(["Secondary", "#A6774E", "#D69861", "Preus, avisos, accents secundaris"])
doc.table_row(["Tertiary", "#324756", "#4B7491", "Informació contextual, codi, icones info"])
doc.table_row(["On Tertiary", "#88C1E9", "#1A2A3D", "Text sobre fons teriari"])
doc.table_row(["Surface", "#FFFFFF", "#201814", "Fons general de l'app"])
doc.table_row(["On Surface", "#201814", "#FFFFFF", "Text principal"])
doc.table_row(["On Primary", "#F2F0F2", "#171512", "Text sobre botons primaris"])
doc.table_row(["On Surface Variant", "#9A979A", "#AFA9AF", "Text secundari, hints"])
doc.table_row(["Error", "#B53A3A", "#EC5E5E", "Errors, eliminar, cancel·lar"])
doc.img_placeholder("PALETA VISUAL: quadrats de cada color amb hex, tema clar i fosc")

doc.heading3("2.3.3 Usabilitat")
doc.body("Principis d'usabilitat aplicats:")
doc.bullet("Navegació inferior persistent (4 pestañes: Inici, Excursions, Equipament, Calendari).")
doc.bullet("Filtres amb xips (FilterChip / ChoiceChip): bottom sheet amb drag handle.")
doc.bullet("Feedback immediat: spinners de càrrega, missatges d'error en camp, diàlegs de confirmació.")
doc.bullet("Formularis validats en temps real: validators centralitzats (campoObligatorio, email regex, enteroPositivo, decimalPositivo).")
doc.bullet("Tema automàtic: l'app detecta preferència del sistema (clar/fosc) i permet canvi manual.")
doc.bullet("Design system intern: catàleg de components (catalog/) com un storybook.")
doc.bullet("Accessibilitat: contrast mínim 4.5:1, etiquetes semàntiques en tots els elements interactius.")

doc.heading2("2.4 Tecnologies")

doc.heading3("2.4.1 Desplegament")
doc.table_row(["Component", "Tecnologia", "Configuració"], is_header=True)
doc.table_row(["Base de dades", "PostgreSQL 16 (Docker)", "Container outventura_postgres, port 5432"])
doc.table_row(["Admin BD", "pgAdmin 4 (Docker)", "Container outventura_pgadmin, port 8080"])
doc.table_row(["Orquestració", "Docker Compose v2", "docker-compose.yml amb 2 serveis + volume"])
doc.table_row(["Backend runtime", "Node.js LTS + NestJS", "npm run start:dev (watch, port 3000)"])
doc.table_row(["Migracions", "Prisma Migrate + Seed", "npx prisma migrate dev / db seed"])
doc.table_row(["Frontend runtime", "Flutter SDK ^3.x", "flutter run (Android/iOS/web)"])

doc.heading3("2.4.2 Backend")
doc.table_row(["Tecnologia", "Versió", "Funció"], is_header=True)
doc.table_row(["NestJS", "^11.0", "Framework REST modular amb DI"])
doc.table_row(["TypeScript", "5.x", "Tipatge estàtic, interfaces, decoradors"])
doc.table_row(["Prisma ORM", "^7.7", "ORM, migracions, seed"])
doc.table_row(["PostgreSQL", "16", "SGBD relacional principal"])
doc.table_row(["@nestjs/jwt", "^11.0", "Generació i validació de tokens JWT"])
doc.table_row(["bcrypt", "^6.0", "Hash de contrasenyes (factor 10)"])
doc.table_row(["class-validator", "^0.15", "Validació declarativa de DTOs"])
doc.table_row(["@nestjs/swagger", "^11.3", "Documentació OpenAPI automàtica"])
doc.table_row(["Docker Compose", "v2", "Orquestració PostgreSQL + pgAdmin"])

doc.heading3("2.4.3 Frontend")
doc.table_row(["Tecnologia", "Versió", "Funció"], is_header=True)
doc.table_row(["Flutter", "SDK ^3.x", "Framework UI multiplataforma"])
doc.table_row(["Dart", "^3.11", "Llenguatge principal"])
doc.table_row(["flutter_riverpod", "^3.3", "Gestió d'estat reactiu"])
doc.table_row(["Dio", "^5.9", "Client HTTP (preparat, no connectat)"])
doc.table_row(["flutter_secure_storage", "^9.2", "Emmagatzematge segur del token JWT"])
doc.table_row(["shared_preferences", "^2.2", "Preferències locals (tema)"])
doc.table_row(["table_calendar", "^3.1", "Calendari mensual interactiu"])
doc.table_row(["intl", "^0.20", "Formatació de dates en espanyol"])

doc.heading3("2.4.4 Disseny")
doc.bullet("Material Design 3 (M3) com a guia base.")
doc.bullet("Figma per als mockups inicials.")
doc.bullet("Sistema de tema personalitzat: app_colors.dart, app_text_styles.dart, app_theme.dart.")
doc.bullet("Catàleg de components (catalog/) com a storybook intern.")
doc.img_placeholder("CAPTURA: catàleg de components (design system) mostrant botons, inputs i cards")

doc.heading2("2.5 Planificació")
doc.table_row(["Fase", "Durada", "Tasques"], is_header=True)
doc.table_row(["1. Anàlisi", "2 setm.", "Requisits, ER, mockups, paleta"])
doc.table_row(["2. Setup", "1 setm.", "NestJS + Prisma + Docker · Flutter + Riverpod"])
doc.table_row(["3. Backend base", "2 setm.", "Mòduls Role, User, Auth (JWT + bcrypt), Category"])
doc.table_row(["4. Backend recursos", "2 setm.", "Mòduls Activity, Equipment, EquipmentStatus, Swagger"])
doc.table_row(["5. Frontend base", "2 setm.", "Tema, widgets globals, login, gestió de sessió"])
doc.table_row(["6. Frontend features", "3 setm.", "Catàleg, formularis, sol·licituds, reserves, calendari"])
doc.table_row(["7. Integració", "1 setm.", "Connexió Dio ↔ API, gestió d'errors"])
doc.table_row(["8. Poliment", "1 setm.", "Millores UI, tests, memòria"])

doc.heading3("2.5.1 Diagrama de Gantt")
doc.img_placeholder("DIAGRAMA DE GANTT: 8 fases en 14 setmanes (abril - juliol 2026)")
doc.page_break()

# ── 3. IMPLEMENTACIÓ ──
doc.heading1("3. Implementació")

doc.heading2("3.1 Desplegament")
doc.body("Estructura Docker:", bold=True)
doc.code(
    "docker-compose.yml\n"
    "├── postgres (PostgreSQL 16)\n"
    "│   ├── POSTGRES_DB: outventura_db\n"
    "│   └── port: 5432\n"
    "├── pgadmin (dpage/pgadmin4)\n"
    "│   └── port: 8080\n"
    "└── volume: postgres_data"
)
doc.body("Comandes principals:")
doc.bullet("docker compose up -d → aixeca BD i pgAdmin.")
doc.bullet("npx prisma migrate dev → aplica migracions.")
doc.bullet("npx prisma db seed → rols (SUPER, ADMIN, USER, GUEST) i 4 usuaris.")
doc.bullet("npm run start:dev → backend en watch mode (port 3000).")
doc.bullet("http://localhost:3000/api → Swagger UI.")
doc.img_placeholder("CAPTURA: Docker Desktop amb contenidors en marxa")
doc.img_placeholder("CAPTURA: Swagger UI amb tots els tags")

doc.heading2("3.2 Backend")
doc.body("Estructura de carpetes:", bold=True)
doc.code(
    "src/\n"
    "├── main.ts           ← Bootstrap, CORS, ValidationPipe, Swagger\n"
    "├── app.module.ts     ← Importa tots els mòduls\n"
    "├── prisma/           ← PrismaService (global)\n"
    "├── auth/             ← Login amb JWT + bcrypt\n"
    "├── role/             ← CRUD de rols\n"
    "├── user/             ← CRUD d'usuaris\n"
    "├── category/         ← CRUD de categories\n"
    "├── activity/         ← CRUD d'activitats + categories\n"
    "├── equipment/        ← CRUD d'equipament + categories\n"
    "└── equipment-status/ ← CRUD d'estats de material"
)

doc.body("Mòduls implementats:", bold=True)
doc.table_row(["Mòdul", "Endpoints", "Operacions DB", "Validacions DTO"], is_header=True)
doc.table_row(["Auth", "POST /auth/login", "findUnique(email) + bcrypt.compare + JWT sign", "email: @IsEmail, password: @MinLength(8)"])
doc.table_row(["Role", "CRUD /role", "Duplicate code check, count users before delete", "code: @IsNotEmpty, description: optional"])
doc.table_row(["User", "CRUD /user", "Duplicate email check, role exists, strips password", "name/surname: @IsNotEmpty, email: @IsEmail, password: @MinLength(8), roleId: @IsInt"])
doc.table_row(["Category", "CRUD /category", "Duplicate code check, _count equipments/activities", "code: @MaxLength(50)"])
doc.table_row(["Activity", "CRUD /activity + assign categories", "M:N connect categories", "title: @IsNotEmpty, dates: @IsDateString, difficulty: 0-100"])
doc.table_row(["Equipment", "CRUD /equipment + assign categories", "M:N connect, includes status+categories", "title: @IsNotEmpty, price_per_day: @Min(0)"])
doc.table_row(["EquipmentStatus", "CRUD /equipment-status", "Duplicate code check", "code: @MaxLength(20)"])

doc.body("Flux d'autenticació:", bold=True)
doc.bullet("1. Client envia POST /auth/login amb { email, password }.")
doc.bullet("2. AuthService busca l'usuari per email (inclou role).")
doc.bullet("3. Compara amb bcrypt.compare().")
doc.bullet("4. Genera JWT { sub: id, email, role: code }. Expiració: 1 dia.")
doc.bullet("5. Retorna { user, access_token }.")
doc.bullet("6. Frontend desa el token a flutter_secure_storage.")

doc.body("Seguretat implementada:", bold=True)
doc.bullet("Contrasenyes hashejades amb bcrypt (factor 10) al seed.")
doc.bullet("Validació global amb ValidationPipe (whitelist + forbidNonWhitelisted + transform).")
doc.bullet("CORS habilitat. Swagger amb documentació completa.")

doc.img_placeholder("CAPTURA: AuthService login + generació JWT")
doc.img_placeholder("CAPTURA: Swagger petició POST /auth/login amb resposta")
doc.img_placeholder("CAPTURA: UserService amb verificació de duplicats")

doc.heading2("3.3 Frontend")
doc.body("Estructura de carpetes:", bold=True)
doc.code(
    "lib/\n"
    "├── main.dart              ← ProviderScope, MaterialApp, tema\n"
    "├── app/theme/             ← AppColors, AppTextStyles, AppTheme\n"
    "├── catalog/               ← Design system intern\n"
    "├── core/\n"
    "│   ├── network/           ← ApiDelay, AuthStorage, DioClient\n"
    "│   ├── utils/             ← DateFormatter, FormValidators, IdGenerator\n"
    "│   └── widgets/           ← 14 widgets reutilitzables\n"
    "├── features/\n"
    "│   ├── auth/              ← Login, perfil, providers\n"
    "│   ├── outventura/        ← 12 pantalles + 5 formularis\n"
    "│   └── preferences/       ← Tema clar/fosc"
)

doc.body("Pantalles implementades (17):", bold=True)
doc.table_row(["Pantalla", "Fitxer", "Funcionalitat"], is_header=True)
doc.table_row(["Login", "login_page.dart", "Auth amb validació, fons imatge, navigate a MainScaffold"])
doc.table_row(["Main Scaffold", "main_scaffold.dart", "BottomNav 4 tabs, detecció de rol"])
doc.table_row(["Home Client", "home_client_page.dart", "Stats, salutació, sol·licituds recents"])
doc.table_row(["Home Admin", "home_admin_page.dart", "Stats globals, botons gestió"])
doc.table_row(["Excursions", "excursions_page.dart", "Llistat filtrable, CRUD amb FAB"])
doc.table_row(["Equipment", "equipment_page.dart", "Llistat filtrable, CRUD"])
doc.table_row(["Sol·licituds", "requests_page.dart", "Accions acceptar/rebutjar/cancelar"])
doc.table_row(["Detall sol·licitud", "request_detail_page.dart", "Materials i preu total"])
doc.table_row(["Reserves", "reservations_page.dart", "Aprovar/rebutjar/devolver/cancelar"])
doc.table_row(["Detall reserva", "reservation_detail_page.dart", "Línies, danys, preu"])
doc.table_row(["Calendari", "calendar_page.dart", "Vista mensual amb badges R/S"])
doc.table_row(["Usuaris", "users_page.dart", "Filtrable per rol/actiu, CRUD"])
doc.table_row(["Form Excursió", "excursion_form_page.dart", "Tots els camps + categories múltiples"])
doc.table_row(["Form Material", "equipment_form_page.dart", "Stock, preu, dany, categories, estat"])
doc.table_row(["Form Sol·licitud", "request_form_page.dart", "Recàlcul materials automàtic"])
doc.table_row(["Form Reserva", "reservation_form_page.dart", "Dates, línies, danys"])
doc.table_row(["Form Usuari", "user_form_page.dart", "Dades personals, rol, estat"])

doc.body("Gestió d'estat amb Riverpod:", bold=True)
doc.body(
    "Cada recurs té un AsyncNotifierProvider amb CRUD simulat i un provider "
    "de filtrat (.family) que combina query, estat, categoria, rang de dates i idUsuari."
)

doc.body("Exemple de codi (selecció amb xips):", bold=True)
doc.code(
    "AppChipWrap(\n"
    "  children: CategoriaActividad.values.map((cat) {\n"
    "    final selected = _controller.categorias.contains(cat);\n"
    "    return AppFilterChip(\n"
    "      label: cat.label,\n"
    "      selected: selected,\n"
    "      onSelected: (_) => setState(() =>\n"
    "        _controller.toggleCategoria(cat)),\n"
    "    );\n"
    "  }).toList(),\n"
    ")"
)

doc.img_placeholder("CAPTURES: Home Client + Home Admin en tema clar")
doc.img_placeholder("CAPTURES: Catàleg excursions amb filtres oberts")
doc.img_placeholder("CAPTURES: Formulari nova excursió")
doc.img_placeholder("CAPTURES: Catàleg material + Formulari material")
doc.img_placeholder("CAPTURES: Sol·licituds + Formulari sol·licitud")
doc.img_placeholder("CAPTURES: Reserves + Diàleg devolució")
doc.img_placeholder("CAPTURES: Calendari mensual amb events")
doc.img_placeholder("CAPTURES: Gestió d'usuaris + Formulari")

doc.heading2("3.4 Disseny")
doc.body(
    "El tema visual es defineix en tres fitxers a lib/app/theme/: "
    "app_colors.dart (22 colors), app_text_styles.dart (10 estils tipogràfics) "
    "i app_theme.dart (ThemeData complet light + dark)."
)
doc.body("Widgets reutilitzables (14 a core/widgets/):", bold=True)
doc.bullet("AddFab, PrimaryButton, SecondaryButton, TertiaryButton, MiniButton")
doc.bullet("AppChoiceChip, AppFilterChip, AppChipWrap")
doc.bullet("AppDateSelector, AppTimeSelector")
doc.bullet("AppDropdownField, AppInputField, AppImagePickerField")
doc.bullet("AppTag, ConfirmDialog, DetailSection, DetailRow, FilterBottomSheet")
doc.img_placeholder("CAPTURES: tema clar vs fosc en 3 pantalles")
doc.img_placeholder("CAPTURA: catàleg de components (design system)")
doc.page_break()

# ── 4. MILLORES FUTURES ──
doc.heading1("4. Millores futures")

doc.body("Backend — Prioritat alta:", bold=True)
doc.bullet("Aplicar AuthGuard JWT a tots els endpoints protegits.")
doc.bullet("Hashear password al crear usuaris (UserService.create).")
doc.bullet("Secret JWT des de variable d'entorn (.env).")
doc.bullet("Mòduls Solicitud i Reserva al backend.")
doc.bullet("Refresh token i invalidació de sessions.")

doc.body("Backend — Prioritat mitjana:", bold=True)
doc.bullet("POST /auth/register per a registre públic.")
doc.bullet("Forgot/Reset password per email.")
doc.bullet("Pujada d'imatges (S3 o Cloudinary).")
doc.bullet("Paginació i filtres avançats.")
doc.bullet("RBAC amb decorator personalitzat.")
doc.bullet("Logging i rate limiting.")

doc.body("Frontend — Prioritat alta:", bold=True)
doc.bullet("Substituir dades fake per crides reals via Dio.")
doc.bullet("Activar AuthStorage i DioClient amb interceptor JWT.")
doc.bullet("Gestió d'errors de xarxa.")

doc.body("Frontend — Prioritat mitjana:", bold=True)
doc.bullet("Pantalla de registre i recuperació de contrasenya.")
doc.bullet("Notificacions push (FCM).")
doc.bullet("Mapa integrat per a punts d'inici/fi.")
doc.bullet("Valoracions d'excursions.")
doc.bullet("Exportació a PDF.")

doc.body("Negoci:", bold=True)
doc.bullet("Passarel·la de pagament (Stripe).")
doc.bullet("Dashboard d'estadístiques.")
doc.bullet("Versió web per a admin.")
doc.bullet("Multi-tenant SaaS.")
doc.bullet("Internacionalització (ca, es, en).")
doc.page_break()

# ── 5. CONCLUSIONS ──
doc.heading1("5. Conclusions")

doc.heading2("5.1 Personals")
doc.body(
    "Ha estat el primer cop que he desenvolupat una aplicació completa full-stack "
    "des de zero, amb un frontend multiplataforma i un backend REST amb base de dades "
    "relacional. El repte més gran ha sigut gestionar el temps: mantenir el ritme "
    "entre frontend i backend alhora, decidir què prioritzar i què deixar per després."
)
doc.body(
    "Flutter m'ha sorprès per bé. El sistema de widgets és molt potent i Riverpod, "
    "tot i que té una corba d'aprenentatge notable, un cop l'entens fa que la gestió "
    "d'estat sigui molt neta. He après a pensar en termes de providers i notifiers, "
    "i a separar la lògica de la UI de manera real."
)
doc.body(
    "De NestJS m'emporto la importància de la modularitat. Tenir cada recurs aïllat "
    "en el seu mòdul fa que el codi sigui fàcil d'entendre i de mantenir. Prisma és "
    "molt còmode i Swagger et documenta la API gairebé sol."
)
doc.body(
    "El que canviaria: hauria connectat el frontend al backend molt abans. Treballar "
    "amb dades fake durant tant de temps va fer que la integració fos una fase a part."
)

doc.heading2("5.2 Tècniques")
doc.body(
    "El projecte ha assolit els objectius principals: una API REST funcional amb "
    "autenticació, una app Flutter amb 17 pantalles completes, un sistema de tema dual, "
    "un design system intern i un entorn de dev containeritzat."
)
doc.body("Assoliments tècnics:")
doc.bullet("Clean Architecture al frontend amb separació domain/data/presentation/services.")
doc.bullet("Riverpod amb AsyncNotifier per a CRUD reactiu i filtrat combinat amb Provider.family.")
doc.bullet("NestJS modular amb 7 mòduls REST, validació amb DTOs i Swagger complet.")
doc.bullet("Prisma ORM amb relacions M:N, seeds i migracions.")
doc.bullet("Docker Compose per a entorn reproducible.")
doc.bullet("Design system intern (catalog/) com a storybook.")
doc.bullet("PricingService amb càlcul automàtic de preus i danys.")
doc.body(
    "El punt feble tècnic és la falta de connexió real front-back i la manca de guards "
    "JWT. Però la base arquitectònica és sòlida per afegir-ho sense grans refactors."
)
doc.page_break()

# ── 6. REFERÈNCIES ──
doc.heading1("6. Referències bibliogràfiques")
refs = [
    "[1] Flutter Documentation. (2024). https://flutter.dev/docs",
    "[2] Dart Documentation. (2024). https://dart.dev/docs",
    "[3] Riverpod. (2024). https://riverpod.dev",
    "[4] NestJS Documentation. (2024). https://docs.nestjs.com",
    "[5] Prisma Documentation. (2024). https://www.prisma.io/docs",
    "[6] PostgreSQL 16. (2024). https://www.postgresql.org/docs/16/",
    "[7] Material Design 3. (2024). https://m3.material.io",
    "[8] Docker Documentation. (2024). https://docs.docker.com",
    "[9] JWT.io. (2024). https://jwt.io/introduction",
    "[10] OpenAPI / Swagger. (2024). https://swagger.io/specification/",
    "[11] bcrypt (npm). (2024). https://www.npmjs.com/package/bcrypt",
    "[12] class-validator. (2024). https://github.com/typestack/class-validator",
    "[13] Dio (pub.dev). (2024). https://pub.dev/packages/dio",
    "[14] table_calendar (pub.dev). (2024). https://pub.dev/packages/table_calendar",
    "[15] flutter_secure_storage. (2024). https://pub.dev/packages/flutter_secure_storage",
]
for ref in refs:
    doc.add_para("Reference", ref)


# ── Generate ───────────────────────────────────────────────────────────────────
doc.save("memoria_outventura_v2.icml")
