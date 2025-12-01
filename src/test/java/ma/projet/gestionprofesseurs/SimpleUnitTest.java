package ma.projet.gestionprofesseurs;

import ma.projet.gestionprofesseurs.entities.Professeur;
import ma.projet.gestionprofesseurs.entities.Specialite;
import org.junit.jupiter.api.Test;

import java.util.Date;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Simple unit tests that don't require Spring context or database connection
 */
class SimpleUnitTest {

    @Test
    void testProfesseurCreation() {
        Specialite specialite = new Specialite("CS", "Computer Science");
        specialite.setId(1);
        
        Professeur professeur = new Professeur();
        professeur.setId(1);
        professeur.setNom("Doe");
        professeur.setPrenom("John");
        professeur.setEmail("john.doe@example.com");
        professeur.setTelephone("123456789");
        professeur.setDateEmbauche(new Date());
        professeur.setSpecialite(specialite);
        
        assertNotNull(professeur);
        assertEquals(1, professeur.getId());
        assertEquals("Doe", professeur.getNom());
        assertEquals("John", professeur.getPrenom());
        assertEquals("john.doe@example.com", professeur.getEmail());
        assertNotNull(professeur.getSpecialite());
    }

    @Test
    void testSpecialiteCreation() {
        Specialite specialite = new Specialite("MATH", "Mathematics");
        specialite.setId(1);
        
        assertNotNull(specialite);
        assertEquals(1, specialite.getId());
        assertEquals("MATH", specialite.getCode());
        assertEquals("Mathematics", specialite.getLibelle());
    }

    @Test
    void testProfesseurGettersAndSetters() {
        Professeur professeur = new Professeur();
        Date date = new Date();
        
        professeur.setId(10);
        professeur.setNom("Smith");
        professeur.setPrenom("Jane");
        professeur.setEmail("jane.smith@example.com");
        professeur.setTelephone("987654321");
        professeur.setDateEmbauche(date);
        
        assertEquals(10, professeur.getId());
        assertEquals("Smith", professeur.getNom());
        assertEquals("Jane", professeur.getPrenom());
        assertEquals("jane.smith@example.com", professeur.getEmail());
        assertEquals("987654321", professeur.getTelephone());
        assertEquals(date, professeur.getDateEmbauche());
    }

    @Test
    void testSpecialiteGettersAndSetters() {
        Specialite specialite = new Specialite();
        
        specialite.setId(5);
        specialite.setCode("PHY");
        specialite.setLibelle("Physics");
        
        assertEquals(5, specialite.getId());
        assertEquals("PHY", specialite.getCode());
        assertEquals("Physics", specialite.getLibelle());
    }
}

