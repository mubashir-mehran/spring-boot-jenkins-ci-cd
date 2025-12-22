package ma.projet.gestionprofesseurs.benchmarks;

import ma.projet.gestionprofesseurs.entities.Professeur;
import ma.projet.gestionprofesseurs.entities.Specialite;
import org.openjdk.jmh.annotations.Scope;
import org.openjdk.jmh.annotations.State;

import java.util.Date;

/**
 * Benchmark state class that provides test data for JMH benchmarks.
 * This state is shared across all benchmark threads.
 */
@State(Scope.Benchmark)
public class BenchmarkState {
    
    public Specialite specialite;
    public Professeur professeur;
    public Date dateDebut;
    public Date dateFin;
    
    public BenchmarkState() {
        // Initialize test data
        specialite = new Specialite("CS", "Computer Science");
        specialite.setId(1);
        
        professeur = new Professeur();
        professeur.setId(1);
        professeur.setNom("Doe");
        professeur.setPrenom("John");
        professeur.setEmail("john.doe@example.com");
        professeur.setTelephone("123456789");
        professeur.setDateEmbauche(new Date());
        professeur.setSpecialite(specialite);
        
        // Initialize date range for date-based queries
        long now = System.currentTimeMillis();
        dateDebut = new Date(now - 365L * 24 * 60 * 60 * 1000); // 1 year ago
        dateFin = new Date(now); // today
    }
}


